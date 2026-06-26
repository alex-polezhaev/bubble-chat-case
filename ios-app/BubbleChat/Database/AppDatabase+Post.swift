import Foundation
import GRDB

extension AppDatabase {
    func findPostWithMembers(postServerId: UUID) async throws -> (post: Post, members: [ChatMember]) {
        try await AppDatabase.shared.dbPool.read { db in
            let existingPost = try Post
                .filter(Column("serverId") == postServerId)
                .fetchOne(db)

            let existingMembers = try ChatMember
                .filter(Column("chatId") == existingPost?.chatId)
                .fetchAll(db)

            if let existingPost, !existingMembers.isEmpty {
                return (existingPost, existingMembers)
            } else {
                throw AppError.database(description: "post desn't exist")
            }
        }
    }
}
