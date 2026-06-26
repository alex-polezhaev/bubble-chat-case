import Foundation

struct CreateChatRequest: Codable {
    var chatType: ChatType
    var receiverIds: [UUID]
    var title: String?
}
