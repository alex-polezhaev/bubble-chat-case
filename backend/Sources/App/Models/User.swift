import Fluent
import Vapor

final class User: Hashable, Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "avatar")
    var avatar: String?

    @Field(key: "phone")
    var phone: String

    @OptionalField(key: "device_token")
    var deviceToken: String?

    init() {}

    init(firstName: String, lastName: String, avatar: String?, phone: String, deviceToken: String?) {
        id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.phone = phone
        self.deviceToken = deviceToken
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

extension PublicUser: Content {}

extension User {
    func asPublic() -> PublicUser {
        return PublicUser(
            id: id!,
            firstName: firstName,
            lastName: lastName,
            avatar: avatar,
            phone: phone
        )
    }

    func asPrivate(accessToken: String) -> PrivateUser {
        return PrivateUser(
            id: id!,
            firstName: firstName,
            lastName: lastName,
            avatar: avatar,
            phone: phone,
            accessToken: accessToken
        )
    }
}
