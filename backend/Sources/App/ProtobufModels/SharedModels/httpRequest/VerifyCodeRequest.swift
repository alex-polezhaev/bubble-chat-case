import Foundation

struct VerifyCodeRequest: Codable {
    var clientCode: String
    var userId: UUID
}
