import Foundation
import GRPC

extension ClientToServerProvider {
    func handleSendCommentReponse(res: Response_SendCommentPayload_Strict, queueRequest _: QueueRequest) async throws {
        try await AppDatabase.shared.dbPool.write { db in
            var comment = try Comment.find(db, key: res.commentClientId)

            comment.status = .sent
            comment.serverId = res.commentServerId

            try comment.save(db)
        }

        playSound(name: "outcome-comment")
    }
}
