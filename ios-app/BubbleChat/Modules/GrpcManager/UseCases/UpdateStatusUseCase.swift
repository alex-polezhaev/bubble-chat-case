import Foundation
import GRDB

class UpdateStatusUseCase {
    let chat: Chat

    let post: Post?
    let comment: Comment?
    let layer: Layer?
    let reaction: Reaction?

    let deliveryStatus: DeliveryStatus

    let myMember: ChatMember

    init(post: Post?, comment: Comment?, layer: Layer?, reaction: Reaction?, deliveryStatus: DeliveryStatus, chat: Chat) throws {
        self.post = post
        self.chat = chat
        self.comment = comment
        self.layer = layer
        self.reaction = reaction
        self.deliveryStatus = deliveryStatus
        myMember = try UserManager.shared.myChatMemberByChatId(chatId: chat.id)
    }

    func execute() async throws {
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        let newTrack = DeliveryTrack(serverId: nil,
                                     member: myMember,
                                     post: post,
                                     comment: comment,
                                     layer: layer,
                                     reaction: reaction,
                                     status: deliveryStatus,
                                     timestamp: Date())

        let payload = Request_SendStatusPayload_Strict(chatServerId: chat.serverId,
                                                       chatMemberServerId: myMember.serverId,
                                                       trackClientId: newTrack.id,
                                                       deliveryStatus: deliveryStatus,
                                                       postServerId: post?.serverId,
                                                       commentServerId: comment?.serverId,
                                                       layerServerId: layer?.serverId,
                                                       reactionServerId: reaction?.serverId,
                                                       timestamp: newTrack.timestamp)

        try QueueRequestManager()
            .pushQueueRequest(method: .sendDeliveryStatus, serializedRequest: payload.toProto().serializedData())

        try await AppDatabase.shared.dbPool.write { [self] db in
            try newTrack.insert(db)

            if let post {
                var entity = try Post.find(db, key: post.id)
                entity.status = deliveryStatus
                try entity.save(db)
            } else if let comment {
                var entity = try Comment.find(db, key: comment.id)
                entity.status = deliveryStatus
                try entity.save(db)
            } else if let layer {
                var entity = try Layer.find(db, key: layer.id)
                entity.status = deliveryStatus
                try entity.save(db)
            } else if let reaction {
                var entity = try Reaction.find(db, key: reaction.id)
                entity.status = deliveryStatus
                try entity.save(db)
            }
        }
    }
}
