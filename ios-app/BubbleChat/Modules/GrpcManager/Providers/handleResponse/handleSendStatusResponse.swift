import Foundation
import GRPC

extension ClientToServerProvider {
    func handleSendStatusReponse(res: Response_SendStatusPayload_Strict, queueRequest _: QueueRequest) async throws {
        try await AppDatabase.shared.dbPool.write { db in
            var track = try DeliveryTrack.find(db, key: res.trackClientId)

            track.status = .sent
            track.serverId = res.trackServerId

            try track.save(db)
        }

//        SoundManager().playSound(name: "outcome-comment")
    }
}
