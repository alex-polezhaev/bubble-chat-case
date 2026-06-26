import Foundation
import GRDB

extension ServerToClientProvider {
    func handleReceiveStatus(_ req: Request_ReceiveStatusPayload_Strict) async throws {
        let (_, members) = try await AppDatabase.shared.findOrFetchChatWithMembers(chatServerId: req.chatServerId)

        guard let senderMember = members.first(where: { $0.serverId == req.chatMemberServerId }) else {
            throw DatabaseError(message: "Member not found")
        }

        _ = try await AppDatabase.shared.dbPool.write { db in
            let post = (req.postServerId == nil) ? nil : try Post
                .filter(Column("serverId") == req.postServerId)
                .fetchOne(db)
            let comment = (req.commentServerId == nil) ? nil : try Comment
                .filter(Column("serverId") == req.commentServerId)
                .fetchOne(db)
            let layer = (req.layerServerId == nil) ? nil : try Layer
                .filter(Column("serverId") == req.layerServerId)
                .fetchOne(db)
            let reaction = (req.reactionServerId == nil) ? nil : try Reaction
                .filter(Column("serverId") == req.reactionServerId)
                .fetchOne(db)

            let newTrack = DeliveryTrack(serverId: req.trackServerId,
                                         member: senderMember,
                                         post: post,
                                         comment: comment,
                                         layer: layer,
                                         reaction: reaction,
                                         status: req.deliveryStatus,
                                         timestamp: req.timestamp)

            try newTrack.insert(db)

            if var post {
                try self.canUpdateStatus(currentStatus: post.status, newStatus: req.deliveryStatus)
                post.status = req.deliveryStatus
                try post.save(db)
            } else if var comment {
                try self.canUpdateStatus(currentStatus: comment.status, newStatus: req.deliveryStatus)
                comment.status = req.deliveryStatus
                try comment.save(db)
            } else if var layer {
                try self.canUpdateStatus(currentStatus: layer.status, newStatus: req.deliveryStatus)
                layer.status = req.deliveryStatus
                try layer.save(db)
            } else if var reaction {
                try self.canUpdateStatus(currentStatus: reaction.status, newStatus: req.deliveryStatus)
                reaction.status = req.deliveryStatus
                try reaction.save(db)
            }

            return newTrack
        }

//        playSound(name: "income-comment")
    }

    @Sendable
    func canUpdateStatus(currentStatus: DeliveryStatus, newStatus: DeliveryStatus) throws {
        let statusOrder: [DeliveryStatus] = [.uploading, .sending, .failed, .sent, .delivered, .read, .edited, .deleted]

        guard let currentIndex = statusOrder.firstIndex(of: currentStatus),
              let newIndex = statusOrder.firstIndex(of: newStatus)
        else {
            throw AppError.unknown(description: "Invalid statusOrder array, cant find \(newStatus) or \(currentStatus)")
        }
        if newIndex >= currentIndex {
            return
        } else {
            throw AppError.database(description: "Bad try to change status to previous")
        }
    }
}
