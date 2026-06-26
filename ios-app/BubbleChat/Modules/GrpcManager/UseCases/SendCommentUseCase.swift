import Foundation

class SendCommentUseCase {
    let text: String
    let post: Post

    let replyToId: UUID?
    let replyEntityType: ChatEntityType?

    let myMember: ChatMember

    init(text: String, post: Post, replyToId: UUID?, replyEntityType: ChatEntityType?, chat: Chat) throws {
        self.text = text
        self.post = post
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        myMember = try UserManager.shared.myChatMemberByChatId(chatId: chat.id)
    }

    func execute() async throws {
        let postServerId: UUID? = post.serverId

        let newComment = try await AppDatabase.shared.dbPool.write { [self] db in
            let newComment = Comment(serverId: nil,
                                     post: post,
                                     member: myMember,
                                     text: text,
                                     replyToId: replyToId,
                                     replyEntityType: replyEntityType,
                                     status: postServerId == nil ? .failed : .sending,
                                     createdAt: Date(),
                                     editedAt: nil)
            try newComment.insert(db)
            return newComment
        }

        guard let postServerId = postServerId else { return }

        let payload = Request_SendCommentPayload_Strict(commentClientId: newComment.id,
                                                        postServerId: postServerId,
                                                        text: text,
                                                        replyToId: replyToId,
                                                        replyEntityType: replyEntityType,
                                                        timestamp: newComment.createdAt)

        try QueueRequestManager()
            .pushQueueRequest(method: .sendComment, serializedRequest: payload.toProto().serializedData())
    }
}
