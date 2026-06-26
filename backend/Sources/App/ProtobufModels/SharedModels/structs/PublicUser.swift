//
//  PublicUser.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 06.10.2024.
//

import Foundation

struct PublicUser: Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var avatar: String?
    var phone: String
}

extension PublicUser {
    init(from userEntity: Entities_PublicUserEntity) throws {
        id = try parseUUID(from: userEntity.userID.server)
        firstName = userEntity.firstName
        lastName = userEntity.lastName
        avatar = userEntity.avatar
        phone = userEntity.phone
    }

    func toProto() -> Entities_PublicUserEntity {
        return Entities_PublicUserEntity.with {
            $0.userID.server = id.uuidString
            $0.firstName = firstName
            $0.lastName = lastName
            if let avatar = avatar {
                $0.avatar = avatar
            }
            $0.phone = phone
        }
    }
}
