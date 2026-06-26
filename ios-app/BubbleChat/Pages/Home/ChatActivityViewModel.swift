import Foundation
import GRDB
import SwiftUICore

class ChatActivityViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private let currentUser = UserManager.shared.getCurrentUser()
    private var cancellable: AnyDatabaseCancellable?

    @Published var title: String?
    @Published var picture: String?

    @Published var postTitle: String?
    @Published var description: String?

    @Published var userStatus: UserStatus?
    @Published var userlastActiveAt: Date?

    @Published var lastStackModel: StackViewModel?
    @Published var lastChatActivityAt: Date?

    @Published var notifyCounter: Int = 0

    init(chat: Chat) {
        switch chat.chatType {
        case .dialogue:
            observeActivity(chatId: chat.id)
        case .group:
            title = chat.title
            picture = chat.picture
        }
    }

    private func observeActivity(chatId: UUID) {
        let observation = ValueObservation.tracking { db in
            let receiver = try ChatMember
                .filter(Column("chatId") == chatId)
                .filter(Column("userId") != self.currentUser.id)
                .fetchOne(db)

            let user = try User.fetchOne(db, key: receiver?.userId)
            let userActivity = try UserActivity.filter(Column("userId") == user?.id).fetchOne(db)
            let contact = try Contact.filter(Column("userId") == user?.id).fetchOne(db)

            // Find the last post in the chat
            let lastPost = try Post
                .filter(Column("chatId") == chatId)
                .order(Column("createdAt").desc) // Sort by creation date in descending order
                .fetchOne(db)

            let lastComment = try Comment
                .filter(Column("postId") == lastPost?.id)
                .order(Column("createdAt").desc) // Sort by creation date in descending order
                .fetchOne(db)

            return (contact, user, userActivity, lastPost, lastComment)
        }

        cancellable = observation.start(
            in: dbPool,
            onError: { error in
                print("Observation failed: \(error)")
            },
            onChange: { [weak self] contact, user, userActivity, lastPost, lastComment in
                guard let self else { return }
                withAnimation {
                    if let contact {
                        self.title = contact.givenName + " " + contact.familyName
                    } else if let user {
                        self.title = user.firstName + " " + user.lastName
                    }
                    if let user {
                        self.picture = user.avatar
                    }

                    if let userActivity {
                        self.userStatus = userActivity.status
                        self.userlastActiveAt = userActivity.lastActiveAt
                    }

                    if let lastPost {
                        self.lastStackModel = StackViewModel(posts: [lastPost])
                        self.postTitle = lastPost.title
                        self.description = lastPost.description
                        self.lastChatActivityAt = lastPost.createdAt
                    }

                    if let lastComment {
                        self.description = lastComment.text

                        if let lastChatActivityAt = self.lastChatActivityAt,
                           lastComment.createdAt > lastChatActivityAt
                        {
                            self.lastChatActivityAt = lastComment.createdAt
                        }
                    }
                }
            }
        )
    }
}
