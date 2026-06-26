import Fluent
import Vapor

final class Media: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    UserIdentifiable
{
    static let schema = "media"

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @Field(key: "client_id")
    var clientId: UUID

    @Parent(key: "user_id")
    var user: User

    // MARK: - Data

    @Enum(key: "media_type")
    var mediaType: MediaType

    @OptionalField(key: "duration")
    var duration: Int?

    init() {}

    init(id: UUID?, clientId: UUID, user: User, mediaType: MediaType, duration: Int?) throws {
        self.id = id
        self.clientId = clientId
        self.$user.id = try user.requireID()
        self.mediaType = mediaType
        self.duration = duration
    }
}

extension Media {
    func asPublic() throws -> PublicMedia {
        try PublicMedia(id: requireID(),
                        userId: $user.id,
                        mediaType: mediaType,
                        duration: duration)
    }
}
