//
//  PrivateUser.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 14.10.2024.
//

import Foundation

struct PrivateUser: Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var avatar: String?
    var phone: String
    var accessToken: String
}
