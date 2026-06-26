// import Foundation
//
// extension DatabaseManager {
//    func updateStatusByEntityType(chatType: ChatType, entityType: DeliveryTrackableEntityType, entityServerId: UUID, timestamp: Date, deliveryStatus: DeliveryStatus) async throws {
//        switch (chatType, entityType) {
//            case (.dialogue, .bubble):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueBubble
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .frame):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueFrame
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .topic):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueTopic
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .question):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueQuestion
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .reaction):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueReaction
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .comment):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueComment
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .commentReaction):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as DialogueCommentReaction
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.dialogue, .layer):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as Layer
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .bubble):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupBubble
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .frame):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupFrame
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .topic):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupTopic
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .question):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupQuestion
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .reaction):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupReaction
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .comment):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupComment
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .commentReaction):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as GroupCommentReaction
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//            case (.group, .layer):
//                var entity: DeliveryTrackable = try findByServerId(serverId: entityServerId) as Layer
//                updateStatus(entity: &entity, status: deliveryStatus, timestamp: timestamp)
//        }
//    }
//
//    private func updateStatus(entity: inout DeliveryTrackable, status: DeliveryStatus, timestamp: Date) {
//        entity.status = status
//        entity.statusUpdatedAt = timestamp
//    }
// }
