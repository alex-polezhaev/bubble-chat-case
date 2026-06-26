import Foundation
import GRPC

extension ClientToServerProvider {
    func handleSendPostReponse(res: Response_SendPostPayload_Strict, queueRequest _: QueueRequest) async throws {
        try await AppDatabase.shared.dbPool.write { db in
            var post = try Post.find(db, key: res.postClientId)

            post.status = .sent
            post.serverId = res.postServerId

            try post.save(db)
        }

        playSound(name: "outcome-post")
    }
}
