import Foundation

enum PostType: String, Codable {
    case bubble, frame, topic
}

extension PostType {
    func toProtoEnum() -> Common_PostType {
        switch self {
        case .bubble: return .bubble
        case .frame: return .frame
        case .topic: return .topic
        }
    }

    init(from protoEnum: Common_PostType) throws {
        switch protoEnum {
        case .bubble: self = .bubble
        case .frame: self = .frame
        case .topic: self = .topic
        default:
            throw ValidationError.invalidField("Invalid PostType: \(protoEnum)")
        }
    }
}
