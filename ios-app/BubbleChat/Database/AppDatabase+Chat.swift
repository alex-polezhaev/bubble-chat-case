import Foundation
import GRDB

extension AppDatabase {
    func findDialogueChatWithContact(contact: Contact) throws -> Chat? {
        try AppDatabase.shared.dbPool.read { db in
            // Step 1: Filter chats with the `dialogue` type
            let dialogues = try Chat
                .filter(Column("chatType") == ChatType.dialogue.rawValue)
                .fetchAll(db)

            let contactUserId = contact.userId
            // Step 2: Check whether a ChatMember exists with the given userId
            for dialogue in dialogues {
                if let dialogueMember = try ChatMember
                    .filter(Column("chatId") == dialogue.id)
                    .filter(Column("userId") == contactUserId)
                    .fetchOne(db)
                {
                    return dialogue
                }
            }

            return nil
        }
    }

    func createChatFromPublic(publicChat: PublicChat) async throws -> Chat {
        try await AppDatabase.shared.dbPool.write { db in
            let newChat = Chat(serverId: publicChat.id,
                               chatType: publicChat.chatType,
                               title: publicChat.title,
                               picture: nil) // TODO:

            try newChat.insert(db)
            return newChat
        }
    }

    func createChatFromServer(users: [User], chatType: ChatType) async throws -> Chat {
        // Request to create a chat
        let response = try await WebRequestManager()
            .createChat(for: users, chatType: chatType)

        return try await saveChatFromServer(response: response).chat
    }

    func saveChatFromServer(response: CreateChatResponse) async throws -> (chat: Chat, members: [ChatMember]) {
        // Create the chat object
        let newChat = Chat(serverId: response.chat.id,
                           chatType: response.chat.chatType,
                           title: response.chat.title,
                           picture: nil) // TODO: add avatar support

        let newMembers = try await response.members.asyncMap { resMember in
            let user = try await self.findOrFetchUser(userServerId: resMember.userId)
            return ChatMember(
                serverId: resMember.id,
                user: user,
                chat: newChat,
                role: resMember.role
            )
        }

        // Save the chat and members to the database
        try await AppDatabase.shared.dbPool.write { db in
            try newChat.insert(db)

            // Save all members
            for member in newMembers {
                try member.insert(db)
            }
        }

        return (newChat, newMembers)
    }

    func findOrFetchChatWithMembers(chatServerId: UUID) async throws -> (chat: Chat, members: [ChatMember]) {
        if let (existingChat, existingMembers) = try await AppDatabase.shared.dbPool.read({ db in
            let existingChat = try Chat
                .filter(Column("serverId") == chatServerId)
                .fetchOne(db)

            let existingMembers = try ChatMember
                .filter(Column("chatId") == existingChat?.id)
                .fetchAll(db)

            if let existingChat, !existingMembers.isEmpty {
                return (existingChat, existingMembers)
            }
            return nil
        }) {
            return (existingChat, existingMembers)
        }

        let response = try await WebRequestManager().fetchChat(chatServerId: chatServerId)

        return try await saveChatFromServer(response: response)
    }
}
