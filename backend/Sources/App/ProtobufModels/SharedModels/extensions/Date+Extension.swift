import Foundation

extension Date {
    /// Converts the current date to `Common_Timestamp`
    func toCommonTimestamp() -> Common_Timestamp {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoDateString = isoDateFormatter.string(from: self)

        return Common_Timestamp.with {
            $0.isoDate = isoDateString
        }
    }
}

extension Date {
    /// Converts `Common_Timestamp` to `Date`
    init(from commonTimestamp: Common_Timestamp) throws {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoDateFormatter.date(from: commonTimestamp.isoDate) else {
            throw ValidationError.invalidField("Invalid ISO8601 date string: \(commonTimestamp.isoDate)")
        }

        self = date
    }
}
