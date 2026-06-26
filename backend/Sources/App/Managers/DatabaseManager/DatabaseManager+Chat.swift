import Fluent
import GRPC
import Vapor

extension DatabaseManager {
    func getChatAndMembers(
        chatId: UUID,
        userId: UUID
    ) async throws -> (
        chat: Chat,
        chatMembers: [ChatMember],
        currentMember: ChatMember,
        membersWithoutMember: [ChatMember]
    ) {
        // 1. Check that the chat exists
        guard let chat = try await Chat.find(chatId, on: db) else {
            throw GRPCStatus(code: .invalidArgument, message: "chat not found")
        }

        // 2. Get all chat participants
        let chatMembers = try await ChatMember.query(on: db)
            .filter(\.$chat.$id == chatId)
            .all()

        // 3. Verify that the current user is a participant of the chat
        guard let currentMember = chatMembers.first(where: { $0.$user.id == userId }) else {
            throw GRPCStatus(code: .invalidArgument, message: "chat member not found")
        }

        // 4. Filter participants excluding the current user
        let membersWithoutMember = chatMembers.filter { $0.$user.id != userId }

        return (chat, chatMembers, currentMember, membersWithoutMember)
    }

    func findOrCreateChatDialogue(users: [User]) async throws -> (chat: Chat, members: [ChatMember]) {
        // 1. Get the user IDs
        let userIds = try users.map { try $0.requireID() }

        // 2. Check whether a dialogue with the same participants already exists
        let potentialChats = try await Chat.query(on: db)
            .filter(\.$chatType == .dialogue) // Filter by the "dialogue" type
            .join(ChatMember.self, on: \Chat.$id == \ChatMember.$chat.$id)
            .filter(ChatMember.self, \.$user.$id ~~ userIds) // Look up chats that include the participants
            .all()

        // Check for an exact match of participants
        for chat in potentialChats {
            let members = try await ChatMember.query(on: db)
                .filter(\.$chat.$id == chat.requireID())
                .all()

            let memberIds = members.map { $0.$user.id }
            if Set(memberIds) == Set(userIds) {
                // If a chat is found, return it together with its participants
                return (chat, members)
            }
        }

        // 3. Create a new dialogue if none is found
        return try await db.transaction { transaction in
            // Create a new chat
            let newDialogue = Chat(chatType: .dialogue, title: nil)
            try await newDialogue.save(on: transaction)

            // Add participants
            var chatMembers: [ChatMember] = []
            for user in users {
                let member = try ChatMember(user: user, chat: newDialogue, role: .member)
                try await member.save(on: transaction)
                chatMembers.append(member)
            }

            return (newDialogue, chatMembers)
        }
    }

    func createChatGroup(title: String?, users: [User]) async throws -> (chat: Chat, members: [ChatMember]) {
        // 3. Create a new dialogue if none is found
        return try await db.transaction { transaction in
            // Create a new chat
            let newGroup = Chat(chatType: .group, title: title)
            try await newGroup.save(on: transaction)

            // Add participants
            var chatMembers: [ChatMember] = []
            for user in users {
                let member = try ChatMember(user: user, chat: newGroup, role: .member)
                try await member.save(on: transaction)
                chatMembers.append(member)
            }

            return (newGroup, chatMembers)
        }
    }
}
