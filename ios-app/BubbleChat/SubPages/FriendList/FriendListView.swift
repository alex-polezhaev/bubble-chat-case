//
//  FriendListView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.09.2024.
//

import Foundation
import Lottie
import SwiftUI

struct FriendListView: View {
    @StateObject var viewModel: FriendListViewModel

    init() {
        _viewModel = StateObject(wrappedValue: FriendListViewModel())
    }

    @State private var searchText = "" // Stores the search text

    var body: some View {
        VStack {
            if (viewModel.contactsWithUser + viewModel.contactsWithoutUser).isEmpty {
                LottieView(animation: .named("loading"))
                    .playing(loopMode: .loop)
                    .frame(width: WIDTH * 0.5)
            } else {
                VStack {
                    Button("create chat") {}
                    // Search field
                    SearchBar(searchText: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 30)

                    ScrollView {
                        VStack(spacing: 16) {
                            BubbleFriendsGroup(contacts: viewModel.contactsWithUser)

                            AddContactGroup(contacts: viewModel.contactsWithoutUser)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }.onAppear {
            ContactManager.shared.forceUpdate()
        }
    }
}
