import Fluent

struct FirstMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        // MARK: - Users

        try await database.schema(User.schema)
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("avatar", .string)
            .field("phone", .string, .required)
            .field("device_token", .string)
            .create()

        try await database.schema("user_activities")
            .id() // Automatically add the id field
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("last_active_at", .datetime, .required)
            .field("is_server_to_client_stream_active", .bool, .required)
            .field("is_client_to_server_stream_active", .bool, .required)
            .field("is_contact_stream_active", .bool, .required)
            .create()

        // MARK: - Chats

        try await database.schema(Chat.schema)
            .id()
            .field("chat_type", .string, .required)
            .field("title", .string)
            .create()

        // MARK: - Chat Members

        try await database.schema(ChatMember.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("chat_id", .uuid, .required, .references(Chat.schema, "id", onDelete: .cascade))
            .field("role", .string, .required)
            .unique(on: "chat_id", "user_id")
            .create()

        // MARK: - Media

        try await database.schema(Media.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("media_type", .string, .required)
            .field("duration", .int)
            .unique(on: "client_id")
            .create()

        // MARK: - Posts

        try await database.schema(Post.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("chat_id", .uuid, .required, .references(Chat.schema, "id", onDelete: .cascade))
            .field("member_id", .uuid, .required, .references(ChatMember.schema, "id", onDelete: .cascade))
            .field("media_id", .uuid, .references(Media.schema, "id", onDelete: .cascade))
            .field("post_type", .string, .required)
            .field("title", .string)
            .field("description", .string)
            .field("reply_to_id", .uuid)
            .field("reply_entity_type", .string)
            .field("delivery_status", .string, .required)
            .field("created_at", .datetime, .required)
            .field("edited_at", .datetime)
            .unique(on: "client_id")
            .create()

        // MARK: - Comments

        try await database.schema(Comment.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("post_id", .uuid, .required, .references(Post.schema, "id", onDelete: .cascade))
            .field("member_id", .uuid, .required, .references(ChatMember.schema, "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("reply_to_id", .uuid)
            .field("reply_entity_type", .string)
            .field("delivery_status", .string, .required)
            .field("created_at", .datetime, .required)
            .field("edited_at", .datetime)
            .unique(on: "client_id")
            .create()

        // MARK: - Layers

        try await database.schema(Layer.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("post_id", .uuid, .required, .references(Post.schema, "id", onDelete: .cascade))
            .field("member_id", .uuid, .required, .references(ChatMember.schema, "id", onDelete: .cascade))
            .field("x", .double, .required)
            .field("y", .double, .required)
            .field("scale", .double, .required)
            .field("rotation", .double, .required)
            .field("type", .string, .required)
            .field("text_attributes", .json)
            .field("gif_attributes", .json)
            .field("sticker_attributes", .json)
            .field("delivery_status", .string, .required)
            .field("created_at", .datetime, .required)
            .field("edited_at", .datetime)
            .unique(on: "client_id")
            .create()

        // MARK: - Reactions

        try await database.schema(Reaction.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("post_id", .uuid, .references(Post.schema, "id", onDelete: .cascade))
            .field("comment_id", .uuid, .references(Comment.schema, "id", onDelete: .cascade))
            .field("chat_entity_type", .string, .required)
            .field("member_id", .uuid, .required, .references(ChatMember.schema, "id", onDelete: .cascade))
            .field("emoji", .string, .required)
            .field("delivery_status", .string, .required)
            .field("created_at", .datetime, .required)
            .field("edited_at", .datetime)
            .unique(on: "client_id")
            .create()

        // MARK: - Contacts

        try await database.schema(Contact.schema)
            .id()
            .field("client_id", .uuid, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("target_user_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("given_name", .string, .required)
            .field("family_name", .string, .required)
            .field("phone_numbers", .array(of: .string), .required)
            .unique(on: "client_id")
            .create()

        // MARK: - HTTP Logs

        try await database.schema(HttpLog.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("method", .string, .required)
            .field("url", .string, .required)
            .field("headers", .json, .required)
            .field("body", .string)
            .field("response_body", .string)
            .field("status_code", .int)
            .field("timestamp", .datetime, .required)
            .create()

        // MARK: - Queue Requests

        try await database.schema(QueueRequest.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("receiver_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("method", .string, .required)
            .field("provider", .string, .required)
            .field("payload", .data, .required)
            .field("success", .bool)
            .field("error_messages", .array(of: .string), .required)
            .field("attempts", .int, .required)
            .field("created_at", .datetime, .required)
            .field("closed_at", .datetime)
            .create()

        // MARK: - Verification Codes

        try await database.schema(VerificationCode.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("code", .string, .required)
            .field("expires_at", .datetime, .required)
            .create()

        // MARK: - Delivery Tracks

        try await database.schema(DeliveryTrack.schema)
            .id() // Primary key
            .field("client_id", .uuid) // Client ID
            .field("post_id", .uuid, .references("posts", "id", onDelete: .cascade))
            .field("comment_id", .uuid, .references("comments", "id", onDelete: .cascade))
            .field("layer_id", .uuid, .references("layers", "id", onDelete: .cascade))
            .field("reaction_id", .uuid, .references("reactions", "id", onDelete: .cascade))
            .field("member_id", .uuid, .required, .references("chat_members", "id", onDelete: .cascade))
            .field("status", .string, .required)
            .field("timestamp", .datetime, .required)
            .unique(on: "client_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(VerificationCode.schema).delete()
        try await database.schema(QueueRequest.schema).delete()
        try await database.schema(HttpLog.schema).delete()
        try await database.schema(Contact.schema).delete()
        try await database.schema(DeliveryTrack.schema).delete()
        try await database.schema(Reaction.schema).delete()
        try await database.schema(Layer.schema).delete()
        try await database.schema(Comment.schema).delete()
        try await database.schema(Media.schema).delete()
        try await database.schema(Post.schema).delete()
        try await database.schema(ChatMember.schema).delete()
        try await database.schema(Chat.schema).delete()
        try await database.schema(User.schema).delete()
        try await database.schema(UserActivity.schema).delete()
    }
}
