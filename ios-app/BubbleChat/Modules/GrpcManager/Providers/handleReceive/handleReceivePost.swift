import Foundation
import GRDB

extension ServerToClientProvider {
    func handleReceivePost(_ req: Request_ReceivePostPayload_Strict) async throws {
        let (chat, members) = try await AppDatabase.shared.findOrFetchChatWithMembers(chatServerId: req.chatServerId)

        let media: Media? = try await {
            if let publicMedia = req.media {
                return try await AppDatabase.shared.findOrCreateMediaFromPublic(publicMedia: publicMedia)
            }
            return nil
        }()

        try await AppDatabase.shared.dbPool.write { db in
            let existingPost = try Post.filter(Column("serverId") == req.postServerId).fetchOne(db)

            if existingPost != nil {
                return
            }

            guard let senderMember = members.first(where: { $0.serverId == req.memberServerId }) else {
                throw DatabaseError(message: "Member not found")
            }

            try Post(serverId: req.postServerId,
                     chat: chat,
                     member: senderMember,
                     postType: req.postType,
                     media: media,
                     title: req.title,
                     description: req.description,
                     replyToId: nil,
                     replyEntityType: nil,
                     status: .delivered,
                     createdAt: req.timestamp,
                     editedAt: nil).save(db)
        }

        playSound(name: "income-post")
        print("Success \(#function)")
    }
}
