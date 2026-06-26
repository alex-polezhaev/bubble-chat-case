import Foundation

func parseUUID(from string: String, fieldName: String = #function) throws -> UUID {
    guard let uuid = UUID(uuidString: string) else {
        throw ValidationError.invalidField("Invalid \(fieldName): \(string)")
    }
    return uuid
}

func parseDate(from isoDate: String, fieldName: String = #function) throws -> Date {
    let isoDateFormatter = ISO8601DateFormatter()
    guard let date = isoDateFormatter.date(from: isoDate) else {
        throw ValidationError.invalidField("Invalid \(fieldName): \(isoDate)")
    }
    return date
}
