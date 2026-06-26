import Fluent
import GRPC
import Vapor

extension ClientToServerProvider {
    func handleSendPost(_ req: Request_SendPostPayload_Strict, user: User) async throws -> Response_SendPostPayload_Strict {
        let userId = try user.requireID()

        // Get the chat and participants
        let (chat, _, chatMember, membersWithoutMember) = try await app.databaseManager.getChatAndMembers(
            chatId: req.chatServerId,
            userId: userId
        )

        // Look up the media content if specified
        let media = try await Media.find(req.media?.id, on: app.db)

        // Create a new post
        let newPost = try Post(
            clientId: req.postClientId,
            chat: chat,
            member: chatMember,
            postType: req.postType,
            media: media,
            title: req.title,
            description: req.description,
            replyToId: req.replyToId,
            replyEntityType: req.replyEntityType,
            status: .sending,
            createdAt: Date(),
            editedAt: nil
        )

        do {
            // Save the post
            try await newPost.save(on: app.db)
        } catch {
            print(String(reflecting: error))
            // On error, look up an existing post with the same clientId
            guard let existedPost = try await Post.query(on: app.db)
                .filter(\.$clientId == req.postClientId)
                .first()
            else {
                throw GRPCStatus(code: .invalidArgument, message: "Cannot create and cannot find post")
            }

            // Return the response if the post already exists
            return try req.asResponse(serverId: existedPost.requireID())
        }

        // Create the payload for the other participants
        let receiverPayload = try req.asReceive(
            memberServerId: chatMember.requireID(),
            serverId: newPost.requireID()
        )

        // Add a task to the queue
        try await QueueRequestManager(app: app).pushQueueRequest(
            method: .receivePost,
            serializedPayload: receiverPayload.toProto().serializedData(),
            chatMembers: membersWithoutMember,
            user: user
        )

        // Push
        let message: String

        switch req.postType {
        case .bubble:
            message = "Bubble" + (media?.duration?.description ?? "") + "sec."
        case .frame:
            message = "New photo card"
        case .topic:
            message = "New post" + (req.title ?? "")
        }

        let push = PushNotification(title: "\(user.firstName) \(user.lastName)", message: message)

        for receiver in membersWithoutMember {
            try await receiver.$user.load(on: app.db)

            Task.detached { [self] in
                await sendPushNotification(to: receiver.user, payload: push, app: app)
            }
        }

        // Return a successful response
        return try req.asResponse(serverId: newPost.requireID())
    }
}
