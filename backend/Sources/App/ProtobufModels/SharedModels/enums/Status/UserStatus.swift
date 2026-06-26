import Foundation

enum UserStatus: String, Codable, Sendable {
    case online
    case offline
    case typing
    case active
    case capturing
}

extension UserStatus {
    func toProtoEnum() -> Common_UserStatus {
        switch self {
        case .online:
            return .online
        case .offline:
            return .offline
        case .typing:
            return .typing
        case .active:
            return .active
        case .capturing:
            return .capturing
        }
    }

    init(from protoEnum: Common_UserStatus) throws {
        switch protoEnum {
        case .online:
            self = .online
        case .offline:
            self = .offline
        case .typing:
            self = .typing
        case .active:
            self = .active
        case .capturing:
            self = .capturing
        default:
            throw ValidationError.invalidField("Invalid Common_UserStatus: \(protoEnum)")
        }
    }
}
