//
//  Replyable.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 23.11.2024.
//

import Foundation

protocol Replyable {
    var replyToId: UUID? { get set } // Identifier of the message this message replies to
    var replyEntityType: ChatEntityType? { get set }
}
