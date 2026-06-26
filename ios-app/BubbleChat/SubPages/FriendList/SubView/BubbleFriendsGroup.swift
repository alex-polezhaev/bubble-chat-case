//
//  BubbleFriendsGroup.swift
//  FriendList
//
//  Created by polezhaev_aleksandr on 06.10.2024.
//

import GRDB
import SwiftUI

struct BubbleFriendsGroup: View {
    @EnvironmentObject var homeSettings: HomeSettings
    @Environment(\.dismiss) var dismiss

    var contacts: [Contact] // Plain prop, when the list does not need to be modified

    @State private var showCount = 3

    var body: some View {
        VStack {
            if !contacts.isEmpty {
                GroupHeader(title: "Bubble friends", counter: contacts.count)
            }

            ForEach(Array(contacts.prefix(showCount)), id: \.self) { contact in // Use the contact identifier
                ContactBadge(buttonTitle: "Chat", contact: contact) {
                    Task {
                        do {
                            if let chat = try AppDatabase.shared.findDialogueChatWithContact(contact: contact) {
                                dismiss()
                                homeSettings.navigationPath.append(chat)
                            } else {
                                guard let user = try await AppDatabase.shared.dbPool.read({ db in
                                    try User.fetchOne(db, key: contact.userId)
                                }) else { return }

                                let newChat = try await AppDatabase.shared.createChatFromServer(users: [user], chatType: .dialogue)

                                dismiss()
                                homeSettings.navigationPath.append(newChat)
                            }
                        } catch {
                            print(error)
                            homeSettings.showAlert(title: "Failed to create dialogue",
                                                   message: "\(error)")
                        }
                    }
                }
            }

            // Show ShowMore only if there are more than 10 "Bubble friends"

            if contacts.count > showCount && !contacts.isEmpty {
                Button(action: {
                    withAnimation {
                        showCount += 10
                    }
                }) {
                    ShowMore() // "Show more" button
                }
            }
        }
    }
}
