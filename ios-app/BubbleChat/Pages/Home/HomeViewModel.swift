import Foundation
import GRDB
import SwiftUICore

class HomeViewModel: ObservableObject {
    @Published var chats: [Chat] = []

    private let dbPool = AppDatabase.shared.dbPool
    private var cancellable: AnyDatabaseCancellable?

    @Published var leftColumn: [Chat] = []
    @Published var rightColumn: [Chat] = []

    init() {
        observeChats()
    }

    func observeChats() {
        let observation = ValueObservation.tracking { db in
            try Chat.fetchAll(db)
        }

        cancellable = observation.start(in: dbPool, scheduling: .immediate) { error in
            print(error)
        } onChange: { [weak self] chats in
            guard let self else { return }
            withAnimation {
                self.chats = chats
                self.leftColumn = self.distributeChats(chats: chats).left
                self.rightColumn = self.distributeChats(chats: chats).right
            }
        }
    }

    private func distributeChats(chats: [Chat]) -> (left: [Chat], right: [Chat]) {
        var leftColumn: [Chat] = []
        var rightColumn: [Chat] = []

        var leftHeight = 0
        var rightHeight = 0

        for chat in chats {
            // Conditionally set the height for each chat if needed (here just 1)
            let chatHeight = 1

            if leftHeight <= rightHeight {
                leftColumn.append(chat)
                leftHeight += chatHeight
            } else {
                rightColumn.append(chat)
                rightHeight += chatHeight
            }
        }

        return (left: leftColumn, right: rightColumn)
    }
}
