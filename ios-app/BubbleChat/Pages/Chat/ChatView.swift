//
//  ChatView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 12.09.2024.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @EnvironmentObject var homeSettings: HomeSettings

    @ObservedObject var activityModel: ChatActivityViewModel
    @StateObject var viewModel: ChatViewModel

    @State var chat: Chat

    init(chat: Chat, activityModel: ChatActivityViewModel?) {
        self.chat = chat
        self.activityModel = activityModel ?? ChatActivityViewModel(chat: chat)
        _viewModel = StateObject(wrappedValue: ChatViewModel(chat: chat))
    }

    var body: some View {
        ZStack {
            VStack {
                if !viewModel.posts.isEmpty {
                    ScrollView {
                        LazyVStack {
                            Spacer().frame(height: 115)

                            ForEach(viewModel.posts.stackByDateAndSender().reversed(), id: \.self) { dayViewStack in
                                DayView(postArrayArray: dayViewStack)
//                                StackPostFastView(posts: postArray)
                            }.scaleEffect(y: -1)
                        }

                        Spacer().frame(height: 120)
                    }.scaleEffect(y: -1)

                } else {
                    Text("No post items found for chat : \(String(describing: activityModel.title)) \n ser\(String(describing: viewModel.serverId)) id:\(viewModel.id)")
                        .padding()
                }
            }
            .background(
                Image("background-pattern-gray")
                    .resizable()
                    .scaledToFill()
            )
            .navigationDestination(isPresented: $homeSettings.showCameraPage) {
                ChatCameraView(chat: chat)
                    .environmentObject(activityModel)
                    .navigationBarBackButtonHidden()
            }

            HeaderTemplate(leftElement: LeftChatHeaderElement(), centerElement: CenterChatHeaderElement(title: activityModel.title, avatar: activityModel.picture, status: activityModel.userStatus), rightElement: Spacer())

            SliderAndWriteButton(onSlide: {
                homeSettings.showCameraPage = true
            }, onClick: {
                homeSettings.showCreatePostSheet = true
            })
        }
        .ignoresSafeArea(.all)
        .background(Color.background)
        .onAppear {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        .environmentObject(viewModel)
        .sheet(isPresented: $homeSettings.showCreatePostSheet) {
            CreatePostSheet()
                .environmentObject(viewModel)
                .environmentObject(activityModel)
        }
    }
}

struct DayView: View {
    let postArrayArray: [[Post]]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let firstPostDate = postArrayArray.first?.first?.createdAt {
                VStack {
                    Text(firstPostDate, style: .date) // Show the date
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .font(.headline)
                        .padding(6)
                        .background(
                            Capsule().fill(.white.opacity(0.4))
                        )
                }.frame(maxWidth: .infinity, alignment: .center)
            }

            ForEach(postArrayArray, id: \.self) { stackViewPosts in
                StackPostFastView(posts: stackViewPosts.reversed())
            }
        }
        .padding(.vertical)
    }
}
