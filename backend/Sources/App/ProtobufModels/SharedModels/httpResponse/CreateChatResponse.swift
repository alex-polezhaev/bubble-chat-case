import Foundation

struct CreateChatResponse: Codable {
    var chat: PublicChat
    var members: [PublicChatMember]
}
