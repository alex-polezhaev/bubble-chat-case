//
//  ChatController.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 29.09.2024.
//

import Fluent
import JWTKit
import SotoS3
import Vapor

struct ChatController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chatRoutes = routes.grouped("chat")

        chatRoutes.grouped(UserIdMiddleware()).post(use: createChat)
        chatRoutes.grouped(UserIdMiddleware()).get(":chatServerId", use: getChat)
    }
}

extension CreateChatResponse: Content {}

extension ChatController {
    @Sendable
    func createChat(req: Request) async throws -> CreateChatResponse {
        let input = try req.content.decode(CreateChatRequest.self)

        guard let user = try await User.find(req.userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        switch input.chatType {
        case .dialogue:
            guard let receiverId = input.receiverIds.first,
                  let receiver = try await User.find(receiverId, on: req.db)
            else {
                throw Abort(.notFound, reason: "Receiver not found")
            }

            let (chat, members) = try await req.application.databaseManager
                .findOrCreateChatDialogue(users: [user, receiver])

            return try CreateChatResponse(chat: chat.asPublic(),
                                          members: members.map { try $0.asPublic() })

        case .group:
            let receivers = try await User.query(on: req.db)
                .filter(\.$id ~~ input.receiverIds) // Find all users whose id is in the userIds array
                .all()

            guard receivers.count >= 1 else {
                throw Abort(.notFound, reason: "Invalid receivers")
            }

            let (chat, members) = try await req.application.databaseManager
                .createChatGroup(title: input.title, users: [user] + receivers)

            return try CreateChatResponse(chat: chat.asPublic(),
                                          members: members.map { try $0.asPublic() })
        }
    }

    @Sendable
    func getChat(req: Request) async throws -> CreateChatResponse {
        // Extract serverId from the route parameters
        guard let chatId = req.parameters.get("chatServerId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing or invalid chat serverId")
        }

        // Look up the chat by serverId
        guard let chat = try await Chat.query(on: req.db)
            .filter(\.$id == chatId)
            .first()
        else {
            throw Abort(.notFound, reason: "Chat not found")
        }

        // Get the chat participants
        let members = try await ChatMember.query(on: req.db)
            .filter(\.$chat.$id == chat.requireID())
            .all()

        // Build the response
        return try CreateChatResponse(
            chat: chat.asPublic(),
            members: members.map { try $0.asPublic() }
        )
    }
}
