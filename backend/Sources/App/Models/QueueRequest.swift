import Fluent
import Vapor

final class QueueRequest: Model, Content, @unchecked Sendable, UserIdentifiable {
    static let schema = "queue_requests"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "receiver_id")
    var receiver: User

    // MARK: - Data

    @Field(key: "method")
    var method: QueueRequestServerMethod

    @Field(key: "provider")
    var provider: QueueRequestGrpcProvider

    @Field(key: "payload")
    var payload: Data

    @Field(key: "success")
    var success: Bool?

    @Field(key: "error_messages")
    var errorMessages: [String]

    // Field for the number of attempts
    @Field(key: "attempts")
    var attempts: Int

    // Field for the creation date
    @Field(key: "created_at")
    var createdAt: Date

    // Field for the update date
    @Field(key: "closed_at")
    var closedAt: Date?

    init() {}

    init(id: UUID?, user: User, receiver: User, method: QueueRequestServerMethod, provider: QueueRequestGrpcProvider, payload: Data, success: Bool?, errorMessages: [String], attempts: Int, createdAt: Date, closedAt: Date?) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$receiver.id = try receiver.requireID()
        self.method = method
        self.provider = provider
        self.payload = payload
        self.success = success
        self.errorMessages = errorMessages
        self.attempts = attempts
        self.createdAt = createdAt
        self.closedAt = closedAt
    }
}

enum QueueRequestServerMethod: String, Codable {
    case receivePost,
         receiveComment,
         receiveLayer,
         receiveReaction,
         receiveDeliveryStatus
}
