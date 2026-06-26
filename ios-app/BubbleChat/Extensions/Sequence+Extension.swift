import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        var results: [T] = []
        for element in self {
            try await results.append(transform(element))
        }
        return results
    }
}
