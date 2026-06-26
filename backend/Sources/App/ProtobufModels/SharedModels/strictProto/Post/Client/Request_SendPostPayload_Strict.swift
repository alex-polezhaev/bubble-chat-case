import Foundation

struct Request_SendPostPayload_Strict: Codable {
    var postClientId: UUID
    var chatServerId: UUID

    var postType: PostType
    var media: PublicMedia?
    var title: String?
    var description: String?

    var replyToId: UUID?
    var replyEntityType: ChatEntityType?

    var timestamp: Date

    init(
        postClientId: UUID,
        chatServerId: UUID,
        postType: PostType,
        media: PublicMedia?,
        title: String?,
        description: String?,
        replyToId: UUID?,
        replyEntityType: ChatEntityType?,
        timestamp: Date
    ) throws {
        self.postClientId = postClientId
        self.chatServerId = chatServerId
        self.postType = postType
        self.media = media
        self.title = title
        self.description = description
        self.replyToId = replyToId
        self.replyEntityType = replyEntityType
        self.timestamp = timestamp
    }

    // Initialization from the gRPC model with validation
    init(from entity: Entities_PostEntity) throws {
        postClientId = try parseUUID(from: entity.postID.client)
        chatServerId = try parseUUID(from: entity.chatID.server)
        postType = try PostType(from: entity.postType)
        media = try? PublicMedia(from: entity.mediaEntity)
        title = entity.title
        description = entity.descriptionText
        replyToId = try? parseUUID(from: entity.replyEntity.replyToID.server)
        replyEntityType = try? ChatEntityType(from: entity.replyEntity.replyEntityType)
        timestamp = try parseDate(from: entity.timestamp.isoDate)
    }

    // Conversion to the gRPC model with validation
    func toProto() throws -> Entities_PostEntity {
        let result = try Entities_PostEntity.with {
            $0.postID.client = postClientId.uuidString
            $0.chatID.server = chatServerId.uuidString
            $0.postType = postType.toProtoEnum()
            $0.timestamp.isoDate = timestamp.ISO8601Format()

            if let media = media {
                $0.mediaEntity = try media.toProto()
            }
            if let replyToId = replyToId, let replyEntityType = replyEntityType {
                $0.replyEntity = Entities_ReplyEntity.with {
                    $0.replyToID.server = replyToId.uuidString
                    $0.replyEntityType = replyEntityType.toProtoEnum()
                }
            }
            if let title = title {
                $0.title = title
            }
            if let description = description {
                $0.descriptionText = description
            }
        }

        do {
            // Check that the fields are filled in
            let _ = try Request_SendPostPayload_Strict(from: result)
        } catch {
            fatalError(#file)
        }
        return result
    }
}

extension Request_SendPostPayload_Strict {
    func asResponse(serverId: UUID) -> Response_SendPostPayload_Strict {
        return Response_SendPostPayload_Strict(postClientId: postClientId,
                                               postServerId: serverId,
                                               timestamp: timestamp)
    }

    func asReceive(memberServerId: UUID, serverId: UUID) -> Request_ReceivePostPayload_Strict {
        return Request_ReceivePostPayload_Strict(postServerId: serverId,
                                                 chatServerId: chatServerId,
                                                 memberServerId: memberServerId,
                                                 postType: postType,
                                                 media: media,
                                                 title: title,
                                                 description: description,
                                                 replyToId: replyToId,
                                                 replyEntityType: replyEntityType,
                                                 timestamp: timestamp)
    }
}
