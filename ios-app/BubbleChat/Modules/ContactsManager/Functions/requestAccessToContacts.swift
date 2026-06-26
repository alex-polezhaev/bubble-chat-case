import Contacts

// Async function to request access to contacts
func requestAccessToContacts() async -> Bool {
    let store = CNContactStore()

    // Use withCheckedContinuation to handle the asynchronous call
    return await withCheckedContinuation { continuation in
        store.requestAccess(for: .contacts) { granted, _ in
            continuation.resume(returning: granted)
        }
    }
}
