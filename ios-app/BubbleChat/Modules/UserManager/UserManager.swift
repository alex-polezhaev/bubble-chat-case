//
//  UserManager.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.10.2024.
//
import Foundation
import GRDB

final class UserManager {
    static let shared = UserManager()

    private var currentUser: User?
    private var currentUserActivity: UserActivity?

    private var myMembers: [ChatMember] = []

    private var cancellable: AnyDatabaseCancellable?

    private init() {}

    func observeMyData() throws {
        guard let userIdString = UserDefaults.standard.string(forKey: "id"),
              let userId = UUID(uuidString: userIdString)
        else {
            throw AppError.unknown(description: "current user id not found in UserDefaults")
        }

        let observation = ValueObservation.tracking { db in
            guard let user = try User
                .filter(Column("serverId") == userId)
                .fetchOne(db)
            else {
                throw AppError.unknown(description: "current user id not found in UserDefaults")
            }

            self.currentUser = user

            let userActivity = try UserActivity
                .filter(Column("userId") == user.id)
                .fetchOne(db)
//            else {
            ////                throw AppError.unknown(description: "user activity not found in UserDefaults")
//            }

            self.currentUserActivity = userActivity

            let myMembers = try ChatMember
                .filter(Column("userId") == user.id)
                .fetchAll(db)

            self.myMembers = myMembers

            return (user, userActivity, myMembers)
        }

        cancellable = observation.start(
            in: AppDatabase.shared.dbPool,
            scheduling: .immediate,
            onError: { error in
                print("Observation failed: \(error)")
            },
            onChange: { [weak self] user, userActivity, myMembers in
                guard let self else { return }

                self.currentUser = user
                self.currentUserActivity = userActivity
                self.myMembers = myMembers
            }
        )
    }

    func getCurrentUser() -> User {
        guard let user = currentUser else {
            fatalError("Current user is not loaded. Make sure to call loadUserFromDefaults first.")
        }
        return user
    }

    func checkIfMyMember(memberId: UUID) -> Bool {
        return myMembers.contains(where: { $0.id == memberId })
    }

    func myChatMemberByChatId(chatId: UUID) throws -> ChatMember {
        guard let myMember = myMembers.first(where: { $0.chatId == chatId }) else {
            throw AppError.database(description: "no my member try to send bubble")
        }

        return myMember
    }
}
