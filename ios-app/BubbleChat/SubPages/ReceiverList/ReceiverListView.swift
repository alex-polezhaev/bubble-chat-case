//
//  ReceiverListView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 22.09.2024.
//

import Alamofire
import Foundation
import Kingfisher
import Lottie
import SwiftUI

struct ReceiverListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeSettings: HomeSettings

    @StateObject var viewModel: ReceiverListViewModel

    init(selectedChat: Binding<Chat?>) {
        _viewModel = StateObject(wrappedValue: ReceiverListViewModel())
        _selectedChat = selectedChat
    }

    @Binding var selectedChat: Chat? // Binding for the selected contact

    @State private var searchText = "" // Stores the search text

    var body: some View {
        if viewModel.contactsWithUser.isEmpty {
            LottieView(animation: .named("loading"))
                .playing(loopMode: .loop)
                .frame(width: WIDTH * 0.5)
        } else {
            VStack {
                // Search field
                SearchBar(searchText: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 30)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.contactsWithUser, id: \.id) { contact in
                            ContactBadge(buttonTitle: "Select", contact: contact) {
                                Task {
                                    do {
                                        if let chat = try AppDatabase.shared.findDialogueChatWithContact(contact: contact) {
                                            dismiss()
                                            selectedChat = chat
                                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                        } else {
                                            guard let user = try await AppDatabase.shared.dbPool.read({ db in
                                                try User.fetchOne(db, key: contact.userId)
                                            }) else { return }

                                            let newChat = try await AppDatabase.shared.createChatFromServer(user: user, chatType: .dialogue)

                                            dismiss()
                                            selectedChat = newChat
                                            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                        }
                                    } catch {
                                        print(error)
                                        homeSettings.showAlert(title: "Failed to create dialogue",
                                                               message: "\(error)")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
