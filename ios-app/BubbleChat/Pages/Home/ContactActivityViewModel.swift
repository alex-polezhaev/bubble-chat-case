//
//  ChatActivityViewModel 2.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 18.12.2024.
//

import Foundation
import GRDB
import SwiftUICore

class ContactActivityViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private let currentUser = UserManager.shared.getCurrentUser()
    private var cancellable: AnyDatabaseCancellable?

    @Published var title: String?
    @Published var avatar: String?

    @Published var status: UserStatus?
    @Published var lastActiveAt: Date?

    init(contact: Contact?) {
        guard let contact = contact else { return }
        observeActivity(contactId: contact.id)
    }

    private func observeActivity(contactId: UUID) {
        let observation = ValueObservation.tracking { db in
            let contact = try Contact.fetchOne(db, key: contactId)
            let user = try User.fetchOne(db, key: contact?.userId)
            let userActivity = try UserActivity.filter(Column("userId") == user?.id).fetchOne(db)

            return (contact, user, userActivity)
        }

        cancellable = observation.start(
            in: dbPool,
            scheduling: .immediate,
            onError: { error in
                print("Observation failed: \(error)")
            },
            onChange: { [weak self] contact, user, userActivity in
                guard let self else { return }
                withAnimation {
                    if let user {
                        self.title = user.firstName + " " + user.lastName
                        self.avatar = user.avatar
                    }

                    if let contact {
                        self.title = contact.givenName + " " + contact.familyName
                    }

                    if let userActivity {
                        self.status = userActivity.status
                        self.lastActiveAt = userActivity.lastActiveAt
                    }
                }
            }
        )
    }
}
