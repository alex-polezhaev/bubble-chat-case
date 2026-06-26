//
//  AuthController.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 28.09.2024.
//

import Fluent
import JWTKit
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")

        authRoutes.post("send_code", use: sendCode)
        authRoutes.post("verify_code", use: verifyCode)
        authRoutes.get("check_token_header", use: checkBearerAuthorization)
    }
}

extension PrivateUser: Content {}

extension AuthController {
    @Sendable
    func sendCode(req: Request) async throws -> PublicUser {
        // Extract data from the request
        let sendCodeRequest = try req.content.decode(SendCodeRequest.self)

        // Check for the phone number
        guard !sendCodeRequest.phone.isEmpty else {
            throw Abort(.badRequest, reason: "Phone is required")
        }

        print(sendCodeRequest.phone)

        return try await req.db.transaction { transaction in
            let currentUser: User

            // Check whether a user with this phone number exists
            if let existedUser = try await User.query(on: transaction)
                .filter(\.$phone == sendCodeRequest.phone)
                .first()
            {
                // Update the existing user's data
                existedUser.firstName = sendCodeRequest.firstName
                existedUser.lastName = sendCodeRequest.lastName

                try await existedUser.save(on: transaction)

                currentUser = existedUser
            } else {
                // Create a new user
                let newUser = User(firstName: sendCodeRequest.firstName,
                                   lastName: sendCodeRequest.lastName,
                                   avatar: nil,
                                   phone: sendCodeRequest.phone,
                                   deviceToken: nil)

                try await newUser.save(on: transaction)

                // Create activity for the new user
                let newActivity = try UserActivity(user: newUser,
                                                   lastActiveAt: Date())
                try await newActivity.save(on: transaction)

                currentUser = newUser
            }

            // Generate and send the verification code
            let callResult = CallVerificationResponse(
                status: "+",
                code: "3232",
                call_id: "32323",
                cost: 32,
                balance: 3232
            )

            print("SMS.RU Balance = \(callResult.balance)")

            // Create the verification record
            let verificationCode = try VerificationCode(
                user: currentUser,
                code: callResult.code,
                expiresAt: Date().addingTimeInterval(60 * 2)
            )
            try await verificationCode.save(on: transaction)

            // Return the user's public data
            return currentUser.asPublic()
        }
    }
}

extension AuthController {
    @Sendable
    func verifyCode(req: Request) async throws -> PrivateUser {
        // 1. Extract clientCode from the request body
        let verifyCodeRequest = try req.content.decode(VerifyCodeRequest.self)

        // 3. Look up the user by user_id
        guard let user = try await User.find(verifyCodeRequest.userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        // 4. Look up all verificationCodes for this user
        let verificationCodes = try await VerificationCode.query(on: req.db)
            .filter(\.$user.$id == verifyCodeRequest.userId)
            .filter(\.$expiresAt > Date()) // Codes that have not yet expired
            .all()

        // 5. Look up the code that matches clientCode
        guard verificationCodes.first(where: { $0.code == verifyCodeRequest.clientCode }) != nil else {
            throw Abort(.unauthorized, reason: "Invalid or expired verification code")
        }

        let expiration = ExpirationClaim(value: Date().addingTimeInterval(3600 * 24 * 30 * 12 * 10)) // 10 years (3600 = 1h)

        // Generate the JWT token
        let payload = JwtUserPayload(id: user.id!, phone: user.phone, exp: expiration)
        let token = try req.jwt.sign(payload)

        // Return the response with the user data and the token
        return user.asPrivate(accessToken: token)
    }
}

// MARK: - NGINX Auth

extension AuthController {
    @Sendable
    func checkBearerAuthorization(req: Request) async throws -> Response {
        // Check for the Authorization header
        guard let authorization = req.headers.bearerAuthorization else {
            throw Abort(.forbidden, reason: "Header token authorization required")
        }

        // Extract the token from Bearer
        let accessToken = authorization.token

        do {
            // Verify and decode the token using JWT
            let decoded = try req.jwt.verify(accessToken, as: JwtUserPayload.self)

            // Create the response and set user_id in the header
            let response = Response(status: .ok)
            response.headers.replaceOrAdd(name: "user_id", value: decoded.id.uuidString)

            return response
        } catch {
            // If token validation fails, return 403 Forbidden
            throw Abort(.forbidden, reason: "Invalid or expired token")
        }
    }
}
