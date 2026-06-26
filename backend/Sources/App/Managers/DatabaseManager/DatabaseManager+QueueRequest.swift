import Fluent
import Vapor

extension DatabaseManager {
    func negativeQueueRequest(queueRequest: QueueRequest, errorMessage: String?) throws {
        if queueRequest.attempts > 50 {
            queueRequest.success = false
        }
        if let errorMessage = errorMessage {
            queueRequest.errorMessages.append(errorMessage)
        }

        queueRequest.attempts += 1

        _ = queueRequest.save(on: db)
    }

    func closeQueueRequest(queueRequest: QueueRequest) throws {
        queueRequest.success = true

        _ = queueRequest.save(on: db)
    }
}
