//
//  CameraMenuViewModel.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 22.12.2024.
//

import Foundation
import GRDB
import SwiftUI

class CameraMenuViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private let currentUser = UserManager.shared.getCurrentUser()
    private var cancellable: AnyDatabaseCancellable?

    @Published var selectedChat: Chat? {
        didSet {
            if let chat = selectedChat {
                observeChat(chat: chat)
            }
        }
    }

    @Published var title: String?
    @Published var picture: String?

    @Published var userStatus: UserStatus?
    @Published var userLastActiveAt: Date?

    private func observeChat(chat: Chat) {
        cancellable?.cancel() // Cancel the previous observation if it exists

        switch chat.chatType {
        case .dialogue:
            observeActivity(chatId: chat.id)
        case .group:
            title = chat.title
            picture = chat.picture
        }
    }

    private func observeActivity(chatId: UUID) {
        let observation = ValueObservation.tracking { db in
            let receiver = try ChatMember
                .filter(Column("chatId") == chatId)
                .filter(Column("userId") != self.currentUser.id)
                .fetchOne(db)

            let user = try User.fetchOne(db, key: receiver?.userId)
            let userActivity = try UserActivity.filter(Column("userId") == user?.id).fetchOne(db)
            let contact = try Contact.filter(Column("userId") == user?.id).fetchOne(db)

            return (contact, user, userActivity)
        }

        cancellable = observation.start(
            in: dbPool,
            onError: { error in
                print("Observation failed: \(error)")
            },
            onChange: { [weak self] contact, user, userActivity in
                guard let self = self else { return }
                withAnimation {
                    if let contact {
                        self.title = contact.givenName + " " + contact.familyName
                    } else if let user {
                        self.title = user.firstName + " " + user.lastName
                    }
                    if let user {
                        self.picture = user.avatar
                    }

                    if let userActivity {
                        self.userStatus = userActivity.status
                        self.userLastActiveAt = userActivity.lastActiveAt
                    }
                }
            }
        )
    }
}
