import Foundation

extension DatabaseManager {
//    func findOrCreateUser(publicUser: PublicUser) async throws -> User {
//
//        if let localUser: User = try? findByServerId(serverId: publicUser.id) {
//            return localUser
//        } else {
//            let newUser = User(serverId: publicUser.id,
//                               firstName: publicUser.firstName,
//                               lastName: publicUser.lastName,
//                               avatar: nil,
//                               phone: publicUser.phone,
//                               contact: nil,
//                               activity: nil,
//                               dialogue: nil)
//
//            modelContext.insert(newUser)
//            try modelContext.save()
//            return newUser
//        }
//    }
//
//    func findOrFetchUser(userServerId: UUID) async throws -> User {
//        if let localUser: User = try? findByServerId(serverId: userServerId) {
//            return localUser
//        } else {
//            let serverUser = try await WebRequestManager().fetchUser(userServerId: userServerId)
//
//            let newUser = User(serverId: serverUser.id,
//                              firstName: serverUser.firstName,
//                              lastName: serverUser.lastName,
//                              avatar: nil,
//                              phone: serverUser.phone,
//                              contact: nil,
//                              activity: nil,
//                              dialogue: nil)
//
//            modelContext.insert(newUser)
//            try modelContext.save()
//            return newUser
//        }
//    }
}
