import Vapor

extension Application {
    private struct DatabaseManagerKey: StorageKey {
        typealias Value = DatabaseManager
    }

    var databaseManager: DatabaseManager {
        get {
            guard let manager = storage[DatabaseManagerKey.self] else {
                fatalError("DatabaseManager not configured. Use app.databaseManager = ... in your configure.swift")
            }
            return manager
        }
        set {
            storage[DatabaseManagerKey.self] = newValue
        }
    }
}
