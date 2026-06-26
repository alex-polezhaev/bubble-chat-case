import Foundation
import GRDB
import SwiftUICore

class ReceiverListViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private var cancellable: AnyDatabaseCancellable?

    @Published var contactsWithUser: [Contact] = []

    init() {
        observeContacts()
    }

    func observeContacts() {
        let userId = UserManager.shared.getCurrentUser().id

        let observation = ValueObservation.tracking { db in
            try Contact.fetchAll(db)
        }

        cancellable = observation.start(in: dbPool) { error in
            print(error)
        } onChange: { [weak self] contacts in
            guard let self else { return }

            withAnimation(nil) {
                self.contactsWithUser = contacts.filter { $0.userId != nil }
            }
        }
    }
}
