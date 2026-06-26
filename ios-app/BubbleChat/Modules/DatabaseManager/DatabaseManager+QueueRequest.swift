// import Foundation
//
// extension DatabaseManager {
//    func findPendingRequests() throws -> [QueueRequest] {
//        let fetchRequest = FetchDescriptor<QueueRequest>(predicate: #Predicate { request in
//            request.success == nil
//        })
//        return try modelContext.fetch(fetchRequest)
//    }
//
//    func findQueueRequestById(id: UUID) throws -> QueueRequest {
//        let fetchRequest = FetchDescriptor<QueueRequest>(predicate: #Predicate { request in
//            request.id == id
//        })
//        let requests = try modelContext.fetch(fetchRequest)
//        print(requests.count)
//        guard let request = try modelContext.fetch(fetchRequest).first else {
//            throw AppError.database(description: "No req with id \(id.uuidString)")
//        }
//
//        return request
//    }
//
//    func negativeQueueRequest(queueRequest: QueueRequest, errorMessage: String?) throws {
//        if queueRequest.attempts > 50 {
//            queueRequest.success = false
//        }
//        if let errorMessage = errorMessage {
//            queueRequest.errorMessages.append(errorMessage)
//        }
//
//        queueRequest.attempts += 1
//        queueRequest.updatedAt = Date()
//
//        try modelContext.save()
//    }
//
//    func closeQueueRequest(queueRequest: QueueRequest) throws {
//        queueRequest.success = true
//
//        try modelContext.save()
//    }
// }
