import Foundation

enum ChatEntityType: String, Codable {
    case post, comment
}

extension ChatEntityType {
    func toProtoEnum() -> Common_ChatEntityType {
        switch self {
        case .post: return .post
        case .comment: return .comment
        }
    }

    init(from: Common_ChatEntityType) throws {
        self = switch from {
        case .post:
            .post
        case .comment:
            .comment
        default:
            throw ValidationError.invalidField()
        }
    }
}
