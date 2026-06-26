import Foundation

enum MediaType: String, Codable {
    case video, image
}

extension MediaType {
    func toProtoEnum() -> Common_MediaType {
        switch self {
        case .video:
            .video
        case .image:
            .image
        }
    }

    init(from protoEnum: Common_MediaType) throws {
        switch protoEnum {
        case .video:
            self = .video
        case .image:
            self = .image
        default:
            throw ValidationError.invalidField()
        }
    }
}
