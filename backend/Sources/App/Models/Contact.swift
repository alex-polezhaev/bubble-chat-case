import Fluent
import Vapor

final class Contact: Model, Content, @unchecked Sendable,
    ClientIdentifiable,
    UserIdentifiable
{
    static let schema = "contacts"

    // MARK: - Ident

    @ID(key: .id)
    var id: UUID?

    @Field(key: "client_id")
    var clientId: UUID

    @Parent(key: "user_id")
    var user: User

    // MARK: - Data

    @OptionalParent(key: "target_user_id")
    var targetUser: User?

    @Field(key: "given_name")
    var givenName: String

    @Field(key: "family_name")
    var familyName: String

    @Field(key: "phone_numbers")
    var phoneNumbers: [String]

    init() {}

    init(clientId: UUID,
         user: User,
         targetUser: User?,
         givenName: String,
         familyName: String,
         phoneNumbers: [String])
        throws
    {
        id = UUID()
        self.clientId = clientId
        self.$user.id = try user.requireID()
        self.$targetUser.id = try targetUser?.requireID()
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
    }
}
