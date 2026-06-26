import Foundation

struct PublicChatMember: Codable {
    var id: UUID
    var chatId: UUID
    var userId: UUID
    var role: MemberRole
}
