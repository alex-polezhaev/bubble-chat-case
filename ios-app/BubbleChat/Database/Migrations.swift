import GRDB

extension AppDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createChats") { db in
            try db.create(table: "chats") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).notNull().unique()
                t.column("chatType", .text).notNull()
                t.column("title", .text)
                t.column("picture", .text)
            }
        }

        migrator.registerMigration("createMedia") { db in
            try db.create(table: "media") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("mediaType", .text).notNull()
                t.column("duration", .integer)
            }
        }

        migrator.registerMigration("createUsers") { db in
            try db.create(table: "users") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).notNull().unique()
                t.column("firstName", .text).notNull()
                t.column("lastName", .text).notNull()
                t.column("avatar", .text)
                t.column("phone", .text).notNull().unique()
            }
        }

        migrator.registerMigration("createChatMembers") { db in
            try db.create(table: "chat_members") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).notNull().unique()
                t.column("userId", .text).notNull().references("users", onDelete: .cascade)
                t.column("chatId", .text).notNull().references("chats", onDelete: .cascade)
                t.column("role", .text).notNull()

                t.uniqueKey(["userId", "chatId"])
            }
        }

        migrator.registerMigration("createContacts") { db in
            try db.create(table: "contacts") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("userId", .text).references("users", onDelete: .setNull).unique()
                t.column("givenName", .text).notNull()
                t.column("familyName", .text).notNull()
                t.column("phoneNumbers", .text).notNull()
            }
        }

        migrator.registerMigration("createPosts") { db in
            try db.create(table: "posts") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("chatId", .text).notNull().references("chats", onDelete: .cascade)
                t.column("memberId", .text).notNull().references("chat_members", onDelete: .cascade)
                t.column("postType", .text).notNull()
                t.column("mediaId", .text).references("media", onDelete: .setNull)
                t.column("title", .text)
                t.column("description", .text)
                t.column("replyToId", .text)
                t.column("replyEntityType", .text)
                t.column("status", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("editedAt", .datetime)
            }
        }

        migrator.registerMigration("createQueueRequests") { db in
            try db.create(table: "queue_requests") { t in
                t.column("id", .text).primaryKey()
                t.column("method", .text).notNull()
                t.column("provider", .text).notNull()
                t.column("payload", .blob).notNull()
                t.column("success", .boolean)
                t.column("errorMessages", .blob).notNull()
                t.column("attempts", .integer).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("closedAt", .datetime)
            }
        }

        migrator.registerMigration("createUserActivities") { db in
            try db.create(table: "user_activities") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).notNull().unique()
                t.column("userId", .text).notNull().references("users", onDelete: .cascade).unique()
                t.column("lastActiveAt", .datetime).notNull()
                t.column("status", .text).notNull()
            }
        }

        migrator.registerMigration("createLayers") { db in
            try db.create(table: "layers") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("postId", .text).notNull().references("posts", onDelete: .cascade)
                t.column("memberId", .text).notNull().references("chat_members", onDelete: .cascade)
                t.column("x", .double).notNull()
                t.column("y", .double).notNull()
                t.column("scale", .double).notNull()
                t.column("rotation", .double).notNull()
                t.column("layerType", .text).notNull()
                t.column("textAttributes", .blob)
                t.column("gifAttributes", .blob)
                t.column("stickerAttributes", .blob)
                t.column("status", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("editedAt", .datetime)
            }
        }

        migrator.registerMigration("createComments") { db in
            try db.create(table: "comments") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("postId", .text).notNull().references("posts", onDelete: .cascade)
                t.column("memberId", .text).notNull().references("chat_members", onDelete: .cascade)
                t.column("text", .text).notNull()
                t.column("replyToId", .text)
                t.column("replyEntityType", .text)
                t.column("status", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("editedAt", .datetime)
            }
        }

        migrator.registerMigration("createReactions") { db in
            try db.create(table: "reactions") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("postId", .text).references("posts", onDelete: .setNull)
                t.column("commentId", .text).references("comments", onDelete: .setNull)
                t.column("chatEntityType", .text).notNull()
                t.column("memberId", .text).notNull().references("chat_members", onDelete: .cascade)
                t.column("emoji", .text).notNull()
                t.column("status", .text).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("editedAt", .datetime)
            }
        }

        migrator.registerMigration("createDeliveryTracks") { db in
            try db.create(table: "delivery_tracks") { t in
                t.column("id", .text).primaryKey()
                t.column("serverId", .text).unique()
                t.column("memberId", .text).notNull().references("chat_members", onDelete: .cascade)
                t.column("postId", .text).references("posts", onDelete: .setNull)
                t.column("commentId", .text).references("comments", onDelete: .setNull)
                t.column("layerId", .text).references("layers", onDelete: .setNull)
                t.column("reactionId", .text).references("reactions", onDelete: .setNull)
                t.column("status", .text).notNull()
                t.column("timestamp", .datetime).notNull()
            }
        }

        return migrator
    }
}
