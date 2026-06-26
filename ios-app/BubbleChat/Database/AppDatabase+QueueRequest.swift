import Foundation
import GRDB

extension AppDatabase {
    func negativeAttempt(queueRequestId: UUID, errorMessage: String?) throws {
        try dbPool.write { db in
            guard var req = try QueueRequest.fetchOne(db, key: queueRequestId) else {
                throw AppError.database(description: "no queue request found")
            }

            if req.attempts > 50 {
                req.success = false
            }
            if let errorMessage {
                req.errorMessages.append(errorMessage)
            }

            req.attempts += 1

            try req.save(db)
        }
    }

    func positiveAttempt(queueRequestId: UUID) throws {
        try dbPool.write { db in
            guard var req = try QueueRequest.fetchOne(db, key: queueRequestId) else {
                throw AppError.database(description: "no queue request found")
            }

            req.success = true
            req.attempts += 1

            try req.save(db)
        }
    }
}
