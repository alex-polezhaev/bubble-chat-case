import Foundation

struct PublicChat: Codable {
    var id: UUID
    var chatType: ChatType
    var title: String?
}
