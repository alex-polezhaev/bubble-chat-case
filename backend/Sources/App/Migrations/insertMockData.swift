//
//  insertMockData.swift
//  BubbleBackendVapor
//
//  Created by polezhaev_aleksandr on 29.09.2024.
//

import Fluent
import Vapor

func insertMockData(app: Application) async throws {
    // Check whether data already exists to avoid inserting it again
    let existingCount = try await User.query(on: app.db).count()
    if existingCount > 1 {
        // Data already exists, skip insertion
        return
    }

    // Create mock users
    let users = [
        User(firstName: "Emily",
             lastName: "Johnson",
             avatar: "/images/avatar-1.png",
             phone: "+15550100",
             deviceToken: nil),

        User(
            firstName: "Chris",
            lastName: "Evans",
            avatar: "/images/avatar-2.png",
            phone: "+15550101",
            deviceToken: nil
        ),

        User(
            firstName: "Michael",
            lastName: "Smith",
            avatar: "/images/avatar-3.png",
            phone: "+15550102",
            deviceToken: nil
        ),
        User(
            firstName: "Sophia",
            lastName: "Martinez",
            avatar: "/images/avatar-4.png",
            phone: "+15550103",
            deviceToken: nil
        ),
        User(
            firstName: "David",
            lastName: "Kim",
            avatar: "/images/avatar-5.png",
            phone: "+15550104",
            deviceToken: nil
        ),
        User(
            firstName: "James",
            lastName: "Wilson",
            avatar: "/images/avatar-6.png",
            phone: "+15550105",
            deviceToken: nil
        ),
    ]

    // Save the users to the database
    for user in users {
        try await user.save(on: app.db)
        try await UserActivity(user: user,
                               lastActiveAt: Date()).save(on: app.db)
    }

    print("Mock data inserted")
}
