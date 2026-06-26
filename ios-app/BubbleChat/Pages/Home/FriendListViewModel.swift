import Foundation
import GRDB
import SwiftUICore

class FriendListViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private var cancellable: AnyDatabaseCancellable?

    @Published var contactsWithUser: [Contact] = []
    @Published var contactsWithoutUser: [Contact] = []

    init() {
        observeContacts()
    }

    func observeContacts() {
        let observation = ValueObservation.tracking { db in
            try Contact.fetchAll(db)
        }

        cancellable = observation.start(in: dbPool, scheduling: .immediate) { error in
            print(error)
        } onChange: { [weak self] contacts in
            guard let self else { return }

            withAnimation(nil) {
                self.contactsWithUser = contacts.filter { $0.userId != nil }
                self.contactsWithoutUser = contacts.filter { $0.userId == nil }
            }
        }
    }
}
