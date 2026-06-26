//
//  ContactController.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 01.10.2024.
//

import Fluent
import Vapor

struct ContactController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let contactRoutes = routes.grouped("contact")

        // delete contact
    }
}
