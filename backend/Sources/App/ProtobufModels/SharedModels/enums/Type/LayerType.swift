import Foundation

enum LayerType: String, Codable {
    case text
    case gif
    case sticker
}

extension LayerType {
    func toProtoEnum() -> Common_LayerType {
        switch self {
        case .text:
            .text
        case .gif:
            .gif
        case .sticker:
            .sticker
        }
    }

    init(from protoEnum: Common_LayerType) throws {
        switch protoEnum {
        case .text:
            self = .text
        case .gif:
            self = .gif
        case .sticker:
            self = .sticker
        default:
            throw ValidationError.invalidField("Invalid LayerType: \(protoEnum)")
        }
    }
}
