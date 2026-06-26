import Foundation

final class CacheManager {
    static let shared = CacheManager()

    private init() {} // Singleton

    /// Get the directory for saving files of a specific type
    private func cacheDirectory(for category: String) -> URL {
        let baseDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let categoryDirectory = baseDirectory.appendingPathComponent(category)
        if !FileManager.default.fileExists(atPath: categoryDirectory.path) {
            try? FileManager.default.createDirectory(at: categoryDirectory, withIntermediateDirectories: true)
        }
        return categoryDirectory
    }

    /// Save data to a file
    func save(data: Data, filename: String, category: String) throws -> URL {
        let directory = cacheDirectory(for: category)
        let fileURL = directory.appendingPathComponent(filename)
        try data.write(to: fileURL)
        return fileURL
    }

    /// Load data from a file
    func load(filename: String, category: String) -> Data? {
        let directory = cacheDirectory(for: category)
        let fileURL = directory.appendingPathComponent(filename)
        return FileManager.default.contents(atPath: fileURL.path)
    }

    /// Check whether a file exists
    func fileExists(filename: String, category: String) -> Bool {
        let directory = cacheDirectory(for: category)
        let fileURL = directory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    /// Delete a file
    func delete(filename: String, category: String) throws {
        let directory = cacheDirectory(for: category)
        let fileURL = directory.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    /// Clear all files in a category
    func clearCategory(_ category: String) throws {
        let directory = cacheDirectory(for: category)
        try FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func fileUrl(filename: String, category: String) -> URL? {
        let directory = cacheDirectory(for: category)
        let fileURL = directory.appendingPathComponent(filename)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}
