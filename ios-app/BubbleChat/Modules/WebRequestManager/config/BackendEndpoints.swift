import Moya
import SwiftUI

enum BackendEndpoints {
    case uploadVideoAndPreview(
        clientId: UUID,
        videoUrl: URL,
        previewUrl: URL,
        duration: Int
    )
    case downloadMedia(serverId: UUID, mediaType: MediaType)
    case createChat(request: CreateChatRequest)
    case getUser(userServerId: UUID)
    case getChat(chatServerId: UUID)
    case getMedia(mediaServerId: UUID)
}

extension BackendEndpoints: TargetType {
    var baseURL: URL {
        URL(string: HOST)!
    }

    var path: String {
        switch self {
        case .uploadVideoAndPreview:
            return "/asset/media/video-and-preview"
        case let .downloadMedia(serverId, mediaType):
            return "/asset/download/\(mediaType.rawValue)/\(serverId)"
        case .createChat:
            return "/chat"
        case let .getUser(userServerId):
            return "/users/\(userServerId.uuidString)"
        case let .getChat(chatServerId):
            return "/chat/\(chatServerId.uuidString)"
        case let .getMedia(mediaServerId):
            return "/asset/media/\(mediaServerId.uuidString)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .uploadVideoAndPreview, .createChat:
            return .post
        case .getChat, .getUser, .downloadMedia, .getMedia:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .uploadVideoAndPreview(clientId, videoUrl, previewUrl, duration):
            let multipartData: [MultipartFormData] = [
                MultipartFormData(provider: .data(clientId.uuidString.data(using: .utf8)!), name: "clientId"),
                MultipartFormData(provider: .file(videoUrl), name: "video", mimeType: "video/mp4"),
                MultipartFormData(provider: .file(previewUrl), name: "preview", mimeType: "image/jpeg"),
                MultipartFormData(provider: .data("\(duration)".data(using: .utf8)!), name: "duration"),
            ]
            return .uploadMultipart(multipartData)

        case let .createChat(request):
            return .requestJSONEncodable(request)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .uploadVideoAndPreview:
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
