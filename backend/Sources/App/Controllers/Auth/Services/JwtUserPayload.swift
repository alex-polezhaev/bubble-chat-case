//
//  JwtUserPayload.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 28.09.2024.
//

import JWT
import Vapor

struct JwtUserPayload: JWTPayload {
    var id: UUID
    var phone: String
    var exp: ExpirationClaim

    // Validate the token's expiration
    func verify(using _: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
