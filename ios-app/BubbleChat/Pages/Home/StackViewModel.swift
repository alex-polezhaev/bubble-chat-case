import Foundation
import GRDB
import SwiftUICore

class StackViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private var cancellable: AnyDatabaseCancellable?

    let id: String
    let posts: [Post]

    @Published var currentPost: Post
    var isMine: Bool {
        UserManager.shared.checkIfMyMember(memberId: currentPost.memberId)
    }

    @Published var comments: [Comment] = []

    @Published var currentIndex: Int = 0 {
        didSet {
            currentPost = posts[currentIndex]
        }
    }

    @Published var indexAmount: Int
    @Published var commentsAvatars: [String] = []

    init(posts: [Post]) {
        id = posts.map { $0.id.uuidString }.joined(separator: "-")
        self.posts = posts
        indexAmount = posts.count
        currentPost = posts.first!
        observeComments()
    }

    func nextPost() {
        guard currentIndex < indexAmount - 1 else { return }
        currentIndex += 1
    }

    func observeComments() {
        let observation = ValueObservation.tracking { [self] db in
            try posts.flatMap { try Comment.filter(Column("postId") == $0.id).fetchAll(db) }
        }

        cancellable = observation
            .start(in: dbPool, scheduling: .immediate) { error in
                print(error)
            } onChange: { [weak self] comments in
                guard let self else { return }
                withAnimation {
                    self.comments = comments.sorted { $0.createdAt < $1.createdAt }
                    Task { [weak self] in
                        self?.commentsAvatars = await convertCommentsToAvatars(comments: comments)
                        print(commentsAvatars)
                    }
                }
            }
    }
}

extension StackViewModel {
    func convertCommentsToAvatars(comments: [Comment]) async -> [String] {
        var newArray: [String] = []

        for comment in comments {
            guard let avatar = try? await AppDatabase.shared.dbPool.read({ db in
                let member = try ChatMember.find(db, key: comment.memberId)
                let user = try User.find(db, key: member.userId)
                return user.avatar
            }) else {
                continue
            }

            newArray.append(avatar)
        }

        return Array(Set(newArray))
    }
}
