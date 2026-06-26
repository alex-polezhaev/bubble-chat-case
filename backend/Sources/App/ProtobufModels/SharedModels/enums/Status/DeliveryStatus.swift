import Foundation

enum DeliveryStatus: String, Codable, Sendable {
    case uploading
    case sending // Message is being sent
    case sent // Message sent successfully
    case delivered // Message delivered to the recipient
    case read // Message read by the recipient
    case failed // Message sending error
    case deleted // Message deleted
    case edited // Message edited
}

extension DeliveryStatus {
    func toProtoEnum() -> Common_DeliveryStatus {
        switch self {
        case .uploading:
            return .uploading
        case .sending: // Message is being sent
            return .sending
        case .sent: // Message sent successfully
            return .sent
        case .delivered: // Message delivered to the recipient
            return .delivered
        case .read: // Message read by the recipient
            return .read
        case .failed: // Message sending error
            return .failed
        case .deleted: // Message deleted
            return .deleted
        case .edited:
            return .edited
        }
    }

    init(from protoEnum: Common_DeliveryStatus) throws {
        switch protoEnum {
        case .uploading:
            self = .uploading
        case .sending: // Message is being sent
            self = .sending
        case .sent: // Message sent successfully
            self = .sent
        case .delivered: // Message delivered to the recipient
            self = .delivered
        case .read: // Message read by the recipient
            self = .read
        case .failed: // Message sending error
            self = .failed
        case .deleted: // Message deleted
            self = .deleted
        case .edited:
            self = .edited
        default:
            throw ValidationError.invalidField("Invalid Common_DeliveryStatus: \(protoEnum)")
        }
    }
}
