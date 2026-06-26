//
//  ServerIdentifiable.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 24.11.2024.
//

import Foundation

protocol ServerIdentifiable {
    var id: UUID { get set }
    var serverId: UUID { get set }
}

protocol OptionalServerIdentifiable {
    var id: UUID { get set }
    var serverId: UUID? { get set }
}
