import Fluent
import Vapor

extension ClientToServerProvider {
    func handleSendStatus(_ req: Request_SendStatusPayload_Strict, user: User) async throws -> Response_SendStatusPayload_Strict {
        let userId = try user.requireID()

        // Get the chat participants and the current member
        let (_, _, chatMember, membersWithoutMember) = try await app.databaseManager.getChatAndMembers(
            chatId: req.chatServerId,
            userId: userId
        )

        // Check for or create a DeliveryTrack
        let trackServerId: UUID
        if let existingTrack = try await DeliveryTrack.query(on: app.db)
            .filter(\.$clientId == req.trackClientId)
            .first()
        {
            trackServerId = try existingTrack.requireID()
        } else {
            // Create a new status
            let newStatus = try DeliveryTrack(
                clientId: req.trackClientId,
                post: await Post.find(req.postServerId, on: app.db),
                comment: await Comment.find(req.commentServerId, on: app.db),
                layer: await Layer.find(req.layerServerId, on: app.db),
                reaction: await Reaction.find(req.reactionServerId, on: app.db),
                member: chatMember,
                status: req.deliveryStatus,
                timestamp: req.timestamp
            )

            // Save the new status
            try await newStatus.save(on: app.db)

            // Use requireID() after a successful save
            let newStatusId = try newStatus.requireID()

            // If the status is "read", add a task to the queue
            if req.deliveryStatus == .read {
                let receiverPayload = try req.asReceive(serverId: newStatusId)

                try await QueueRequestManager(app: app).pushQueueRequest(
                    method: .receiveDeliveryStatus,
                    serializedPayload: receiverPayload.toProto().serializedData(),
                    chatMembers: membersWithoutMember,
                    user: user
                )
            }

            trackServerId = newStatusId
        }

        // Return the response
        return req.asResponse(serverId: trackServerId)
    }
}
