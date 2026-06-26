import Foundation
import GRDB
import SwiftUICore

class ChatViewModel: ObservableObject {
    private let dbPool = AppDatabase.shared.dbPool
    private let currentUser = UserManager.shared.getCurrentUser()
    private var cancellable: AnyDatabaseCancellable?

    @Published var posts: [Post] = []

    let id: UUID
    let serverId: UUID?
    let chat: Chat

    init(chat: Chat) {
        id = chat.id
        serverId = chat.serverId
        self.chat = chat

        observePosts(chatId: chat.id)
    }

    private func observePosts(chatId: UUID) {
        let observation = ValueObservation.tracking { db in
            try Post.filter(Column("chatId") == chatId).fetchAll(db)
        }

        cancellable = observation
            .start(in: dbPool, scheduling: .immediate) { error in
                print(error)
            } onChange: { [weak self] posts in
                guard let self else { return }
                withAnimation {
                    self.posts = posts
                }
            }
    }
}

extension Array where Element == Post {
    func stackByDateAndSender() -> [[[Post]]] {
        // Sort posts by creation date
        let sortedPosts = sorted { $0.createdAt < $1.createdAt }

        // Group by one-day intervals
        let groupedByDay = Dictionary(grouping: sortedPosts) { post in
            Calendar.current.startOfDay(for: post.createdAt)
        }

        // Sort the days in ascending order
        let sortedDays = groupedByDay.keys.sorted()

        // Process each day
        return sortedDays.compactMap { day in
            guard let postsForDay = groupedByDay[day] else { return [] }

            var stacks: [[Post]] = []
            var currentStack: [Post] = []
            var lastSender: UUID?

            for post in postsForDay {
                // If it's a topic, finish the current stack and add the topic separately
                if post.postType == .topic {
                    if !currentStack.isEmpty {
                        stacks.append(currentStack)
                    }
                    stacks.append([post]) // Add the topic as a separate stack
                    currentStack = [] // Clear the current stack and start a new one
                    lastSender = nil
                    continue
                }

                // Handle stackable posts (bubble and frame)
                if post.postType == .bubble || post.postType == .frame {
                    if let lastPost = currentStack.last {
                        let timeInterval = post.createdAt.timeIntervalSince(lastPost.createdAt)
                        if post.memberId != lastSender || timeInterval > 30 * 60 {
                            // Finish the current stack and start a new one
                            if !currentStack.isEmpty {
                                stacks.append(currentStack)
                            }
                            currentStack = [post]
                            lastSender = post.memberId
                        } else {
                            // Add the post to the current stack
                            currentStack.append(post)
                        }
                    } else {
                        // Start the first stack
                        currentStack.append(post)
                        lastSender = post.memberId
                    }
                } else {
                    // If it's a non-stackable post, store it separately
                    if !currentStack.isEmpty {
                        stacks.append(currentStack)
                    }
                    stacks.append([post]) // Add as a separate stack
                    currentStack = []
                    lastSender = nil
                }
            }

            // Add the last stack if it's not empty
            if !currentStack.isEmpty {
                stacks.append(currentStack)
            }

            return stacks
        }
    }
}
