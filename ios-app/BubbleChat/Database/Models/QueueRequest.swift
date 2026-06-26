import Foundation
import GRDB

struct QueueRequest: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "queue_requests"

    var id: UUID
    var method: QueueRequestClientMethod
    var provider: QueueRequestGrpcProvider
    var payload: Data
    var success: Bool?
    var errorMessages: [String]
    var attempts: Int
    var createdAt: Date
    var closedAt: Date?

    init(
        method: QueueRequestClientMethod,
        provider: QueueRequestGrpcProvider,
        payload: Data,
        success: Bool?,
        errorMessages: [String],
        attempts: Int,
        createdAt: Date,
        closedAt: Date?
    ) {
        id = UUID()
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

enum QueueRequestClientMethod: String, Codable {
    case sendPost, sendComment, sendDeliveryStatus
}
