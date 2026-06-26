import Foundation

struct PublicUserActivity: Codable, Sendable {
    var id: UUID
    var lastActiveAt: Date
    var userStatus: UserStatus
}

extension PublicUserActivity {
    init(from userActivityEntity: Entities_PublicUserActivityEntity) throws {
        id = try parseUUID(from: userActivityEntity.userActivityID.server)
        lastActiveAt = try Date(from: userActivityEntity.lastActiveAt)
        userStatus = try UserStatus(from: userActivityEntity.userStatus)
    }

    func toProto() -> Entities_PublicUserActivityEntity {
        return Entities_PublicUserActivityEntity.with {
            $0.userActivityID.server = id.uuidString
            $0.lastActiveAt = lastActiveAt.toCommonTimestamp()
            $0.userStatus = userStatus.toProtoEnum()
        }
    }
}
