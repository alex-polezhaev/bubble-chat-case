import Foundation

enum ChatType: String, Codable {
    case dialogue, group
}

extension ChatType {
    func toProtoEnum() -> Common_ChatType {
        switch self {
        case .dialogue:
            .dialogue
        case .group:
            .group
        }
    }

    init(from protoEnum: Common_ChatType) throws {
        switch protoEnum {
        case .dialogue:
            self = .dialogue
        case .group:
            self = .group
        default:
            throw ValidationError.invalidField("Invalid PostType: \(protoEnum)")
        }
    }
}
