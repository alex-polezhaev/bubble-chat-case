import Foundation
import GRDB
import SwiftUICore

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []

    private let dbPool = AppDatabase.shared.dbPool
    private var cancellable: AnyDatabaseCancellable?

    init(posts: [Post]) {
        observeComments(posts: posts)
    }

    func observeComments(posts: [Post]) {
        let observation = ValueObservation.tracking { db in
            var comments: [Comment] = []
            for post in posts {
                comments += try Comment.filter(Column("postId") == post.id).fetchAll(db)
            }

            return comments
        }

        cancellable = observation.start(in: dbPool) { error in
            print(error)
        } onChange: { [weak self] comments in
            guard let self else { return }
            withAnimation {
                self.comments = comments
            }
        }
    }
}
