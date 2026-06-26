import Foundation

protocol MemberIdentifiable {
    var member: ChatMember { get throws }
}
