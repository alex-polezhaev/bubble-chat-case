import Combine
import Foundation

class ContactManager: ObservableObject {
    static let shared = ContactManager()

    private let lastCheckKey = "lastContactsLocalUpdateTime"
    private let userDefaults = UserDefaults.standard

    @Published var inProgress: Bool = false

    private var timerCancellable: AnyCancellable?

    private init() {}

    // Function to check the timestamp and update contacts
    func checkTimestamp() -> Bool {
        // Check the last check time in UserDefaults
        if let lastCheckTime = userDefaults.object(forKey: lastCheckKey) as? Date {
            let timeInterval = Date().timeIntervalSince(lastCheckTime)

            // If more than 12 hours (43200 seconds) have passed, start the update
            if timeInterval > 43200 {
                return true
            }
        } else {
            return true
        }
        return false
    }

    func startUpdating() {
        if inProgress { return }
        if !checkTimestamp() { return }

        forceUpdate()
    }

    func forceUpdate() {
        Task(priority: .userInitiated) {
            print("Contact update started")
            do {
                self.inProgress = true

                try await updateLocalContacts()

                userDefaults.set(Date(), forKey: lastCheckKey)

            } catch {
                print("Error while updating contacts: \(error)")
            }
            self.inProgress = false
        }
    }
}
