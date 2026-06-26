import Fluent
import Vapor

final class HttpLog: Model, Content, @unchecked Sendable {
    static let schema = "http_logs"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "user_id")
    var user: User?

    @Field(key: "method")
    var method: String

    @Field(key: "url")
    var url: String

    @Field(key: "headers")
    var headers: [String: String]

    @Field(key: "body")
    var body: String?

    @Field(key: "response_body")
    var responseBody: String?

    @Field(key: "status_code")
    var statusCode: Int?

    @Field(key: "timestamp")
    var timestamp: Date

    init() {}

    init(
        userId: UUID?,
        method: String,
        url: String,
        headers: [String: String],
        body: String?,
        responseBody: String?,
        statusCode: Int?,
        timestamp: Date
    ) {
        id = UUID()
        $user.id = userId
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.responseBody = responseBody
        self.statusCode = statusCode
        self.timestamp = timestamp
    }
}
