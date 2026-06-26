//
//  UserIdMiddleware.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 10.11.2024.
//

import Vapor

// Create a dedicated key type to store userId in storage
private struct UserIdKey: StorageKey {
    typealias Value = UUID
}

struct UserIdMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Check for the `user_id` header
        guard let userIdString = request.headers["user_id"].first,
              let userId = UUID(uuidString: userIdString)
        else {
            throw Abort(.badRequest, reason: "user_id not found in headers or has an invalid format.")
        }

        // Store `user_id` as a required value on the `request` object using the key
        request.storage[UserIdKey.self] = userId

        // Pass the request further down the chain
        return try await next.respond(to: request)
    }
}

// Extension for convenient access to the required userId from request
extension Request {
    var userId: UUID {
        guard let userId = storage[UserIdKey.self] else {
            fatalError("userId must be extracted and set in the Middleware")
        }
        return userId
    }
}
