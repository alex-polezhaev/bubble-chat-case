import Foundation

class SendPostUseCase {
    let videoUrl: URL?

    let chat: Chat

    let title: String?
    let description: String?

    let postType: PostType

    let replyToId: UUID?
    let replyEntityType: ChatEntityType?

    let myMember: ChatMember

    init(videoUrl: URL?, chat: Chat, title: String?, description: String?, replyToId: UUID?, replyEntityType: ChatEntityType?, postType: PostType) throws {
        self.postType = postType
        self.videoUrl = videoUrl
        self.chat = chat
        self.title = title
        self.description = description
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        myMember = try UserManager.shared.myChatMemberByChatId(chatId: chat.id)
    }

    func execute(completion: () -> Void) async throws {
        // Hand off the post and release

        let newPost = try await AppDatabase.shared.dbPool.write { [self] db in
            let newPost = Post(serverId: nil,
                               chat: chat,
                               member: myMember,
                               postType: postType,
                               media: nil,
                               title: title,
                               description: description,
                               replyToId: replyToId,
                               replyEntityType: replyEntityType,
                               status: .uploading,
                               createdAt: Date(),
                               editedAt: nil)
            try newPost.insert(db)
            return newPost
        }

        if postType == .topic {
            completion()
        }

        // Add the video without sending
        var publicMedia: PublicMedia?

        if let videoUrl {
            let mediaClientId = UUID()

            let croppedUrl = try await cropVideoToSquare(inputURL: videoUrl, videoClientId: mediaClientId)
            let (previewUrl, duration) = try await extractPreviewAndDuration(from: croppedUrl, videoClientId: mediaClientId)

            let newMedia = try await AppDatabase.shared.dbPool.write { db in
                let newMedia = Media(id: mediaClientId,
                                     serverId: nil,
                                     mediaType: .video,
                                     duration: duration)

                try newMedia.insert(db)

                var post = try Post.fetchOne(db, key: newPost.id)
                post?.mediaId = newMedia.id
                post?.status = .sending
                try post?.save(db)

                return newMedia
            }
            if postType == .bubble || postType == .frame {
                completion()
            }

            do {
                let videoResponse = try await WebRequestManager()
                    .sendPostVideo(videoUrl: croppedUrl,
                                   previewUrl: previewUrl,
                                   duration: duration,
                                   clientId: mediaClientId)

                try await AppDatabase.shared.dbPool.write { db in
                    var media = try Media.fetchOne(db, key: newMedia.id)

                    media?.serverId = videoResponse.id
                    try media?.save(db)

                    var post = try Post.fetchOne(db, key: newPost.id)
                    post?.status = .sending

                    try post?.save(db)
                }
            } catch {
                try await AppDatabase.shared.dbPool.write { db in
                    var post = try Post.fetchOne(db, key: newPost.id)
                    post?.status = .failed

                    try post?.save(db)
                }
                return
            }

            publicMedia = try await AppDatabase.shared.dbPool.read { db in
                try Media.find(db, key: newMedia.id).asPublic()
            }
        }

        let payload = try Request_SendPostPayload_Strict(postClientId: newPost.id,
                                                         chatServerId: chat.serverId,
                                                         postType: postType,
                                                         media: publicMedia,
                                                         title: title,
                                                         description: description,
                                                         replyToId: replyToId,
                                                         replyEntityType: replyEntityType,
                                                         timestamp: newPost.createdAt)

        try QueueRequestManager()
            .pushQueueRequest(method: .sendPost, serializedRequest: payload.toProto().serializedData())
    }
}
