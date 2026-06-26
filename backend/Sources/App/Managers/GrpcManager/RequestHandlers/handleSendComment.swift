import Fluent
import GRPC
import Vapor

extension ClientToServerProvider {
    func handleSendComment(_ req: Request_SendCommentPayload_Strict, user: User) async throws -> Response_SendCommentPayload_Strict {
        let userId = try user.requireID()

        // 1. Check that the post exists in the chat
        guard let post = try await Post.query(on: app.db)
            .with(\.$chat)
            .filter(\.$id == req.postServerId)
            .first()
        else {
            throw GRPCStatus(code: .invalidArgument, message: "post not found")
        }

        let (chat, _, chatMember, _) = try await app.databaseManager.getChatAndMembers(
            chatId: post.chat.requireID(),
            userId: userId
        )

        // 2. Check for or create the comment
        let commentServerId: UUID
        if let existingComment = try await Comment.query(on: app.db)
            .filter(\.$clientId == req.commentClientId)
            .filter(\.$post.$id == post.requireID())
            .first()
        {
            commentServerId = try existingComment.requireID()
        } else {
            let newComment = try Comment(
                clientId: req.commentClientId,
                post: post,
                member: chatMember,
                text: req.text,
                replyToId: req.replyToId,
                replyEntityType: req.replyEntityType,
                status: .sending,
                createdAt: Date(),
                editedAt: nil
            )
            try await newComment.save(on: app.db)
            commentServerId = try newComment.requireID()

            // 3. Send to the counterparties
            let receivers = try await ChatMember.query(on: app.db)
                .with(\.$user)
                .filter(\.$chat.$id == chat.requireID())
                .filter(\.$user.$id != userId)
                .all()

            let receiverPayload = try req.asReceive(memberServerId: chatMember.requireID(), serverId: commentServerId)

            try await QueueRequestManager(app: app)
                .pushQueueRequest(
                    method: .receiveComment,
                    serializedPayload: receiverPayload.toProto().serializedData(),
                    chatMembers: receivers,
                    user: user
                )

            // Push

            let push = PushNotification(title: "\(user.firstName) \(user.lastName)", message: newComment.text)

            for receiver in receivers {
                Task.detached { [self] in
                    await sendPushNotification(to: receiver.user, payload: push, app: app)
                }
            }
        }

        // 4. Return the response
        return req.asResponse(serverId: commentServerId)
    }
}
