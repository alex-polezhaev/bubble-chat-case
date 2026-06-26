import Fluent
import Foundation
import GRPC

extension ServerToClientProvider {
    func handleResponseAndSendStatus(res _: Responses_ClientResponse, queueRequest: QueueRequest) async throws {
        var chat: Chat?

        var post: Post?
        var comment: Comment?
        var layer: Layer?
        var reaction: Reaction?

        var timestamp: Date

        switch queueRequest.method {
        case .receivePost:
            let payload = try Entities_PostEntity(serializedBytes: queueRequest.payload)
            let strict = try Request_ReceivePostPayload_Strict(from: payload)
            timestamp = strict.timestamp

            post = try await Post.find(strict.postServerId, on: app.db)
            chat = try await Chat.find(strict.chatServerId, on: app.db)
        case .receiveComment:
            let payload = try Entities_CommentEntity(serializedBytes: queueRequest.payload)
            let strict = try Request_ReceiveCommentPayload_Strict(from: payload)
            timestamp = strict.timestamp

            comment = try await Comment.query(on: app.db)
                .with(\.$post) { $0.with(\.$chat) }
                .filter(\.$id == strict.commentServerId)
                .first()
            chat = comment?.post.chat
        case .receiveLayer:
            let payload = try Entities_LayerEntity(serializedBytes: queueRequest.payload)
            let strict = try Request_ReceiveLayerPayload_Strict(from: payload)
            timestamp = strict.timestamp

            layer = try await Layer.query(on: app.db)
                .with(\.$post) { $0.with(\.$chat) }
                .filter(\.$id == strict.layerServerId)
                .first()
            chat = layer?.post.chat
        case .receiveReaction:
            let payload = try Entities_ReactionEntity(serializedBytes: queueRequest.payload)
            let strict = try Request_ReceiveReactionPayload_Strict(from: payload)
            timestamp = strict.timestamp

            reaction = try await Reaction.query(on: app.db)
                .with(\.$post) { $0.with(\.$chat) }
                .with(\.$comment) { $0.with(\.$post) { $0.with(\.$chat) } }
                .filter(\.$id == strict.reactionServerId)
                .first()

            if let postChat = reaction?.post?.chat {
                chat = postChat
            } else if let commentChat = reaction?.comment?.post.chat {
                chat = commentChat
            }
        case .receiveDeliveryStatus:
            return
        }

        guard let chat, let chatId = try? chat.requireID() else {
            return print(#file + #function + ": No chat found")
        }

        let chatMembers = try await ChatMember.query(on: app.db)
            .with(\.$user)
            .filter((\.$chat.$id == chatId))
            .all()

        guard let memberSender = try chatMembers.first(where: {
            try $0.user.requireID() == queueRequest.receiver.requireID()
        }) else {
            return print(#file + #function + ": No member found 1")
        }
        try await queueRequest.$user.load(on: app.db)

        guard let memberReceiver = try chatMembers.first(where: {
            try $0.user.requireID() == queueRequest.user.requireID()
        }) else {
            return print(#file + #function + ": No member found 2")
        }

        let newTrack = try DeliveryTrack(clientId: nil,
                                         post: post,
                                         comment: comment,
                                         layer: layer,
                                         reaction: reaction,
                                         member: memberSender,
                                         status: .delivered,
                                         timestamp: timestamp)
        try await newTrack.save(on: app.db)

        let payload = try Request_ReceiveStatusPayload_Strict(chatServerId: chat.requireID(),
                                                              chatMemberServerId: memberSender.requireID(),
                                                              trackServerId: newTrack.requireID(),
                                                              deliveryStatus: .delivered,
                                                              postServerId: post?.id,
                                                              commentServerId: comment?.id,
                                                              layerServerId: layer?.id,
                                                              reactionServerId: reaction?.id,
                                                              timestamp: timestamp)

        try await QueueRequestManager(app: app)
            .pushQueueRequest(method: .receiveDeliveryStatus,
                              serializedPayload: payload.toProto().serializedData(),
                              chatMembers: [memberReceiver], user: queueRequest.receiver)
    }
}
