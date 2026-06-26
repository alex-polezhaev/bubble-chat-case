import Foundation
import GRDB

extension ServerToClientProvider {
    func handleReceiveComment(_ req: Request_ReceiveCommentPayload_Strict) async throws {
        let (post, members) = try await AppDatabase.shared.findPostWithMembers(postServerId: req.postServerId)

        try await AppDatabase.shared.dbPool.write { db in
            let existingComment = try Comment.filter(Column("serverId") == req.commentServerId).fetchOne(db)

            if existingComment != nil {
                return
            }

            guard let senderMember = members.first(where: { $0.serverId == req.memberServerId }) else {
                throw DatabaseError(message: "Member not found")
            }

            try Comment(serverId: req.commentServerId,
                        post: post,
                        member: senderMember,
                        text: req.text,
                        replyToId: req.replyToId,
                        replyEntityType: req.replyEntityType,
                        status: .delivered,
                        createdAt: req.timestamp,
                        editedAt: nil).save(db)
        }
        playSound(name: "income-comment")
        print("Success \(#function)")
    }
}
