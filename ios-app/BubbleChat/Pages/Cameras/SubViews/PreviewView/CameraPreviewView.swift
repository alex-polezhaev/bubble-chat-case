//
//  CameraPreviewView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.11.2024.
//

import SwiftUI

struct CameraPreviewView: View {
    @EnvironmentObject var homeSettings: HomeSettings

    @StateObject var playerModel: PlayerViewModel
    @Environment(\.dismiss) var dismiss

    private let cameraManager = CameraManager.shared

    @Binding var selectedChat: Chat?

    @State var isLoading: Bool = false

    init(videoUrl: URL, selectedChat: Binding<Chat?>) {
        _selectedChat = selectedChat
        _playerModel = StateObject(wrappedValue: PlayerViewModel(videoUrl: videoUrl))
    }

    var body: some View {
        if !isLoading {
            VStack {
                ZStack {
                    PlayerVideoLayer()
                    PlayerControlLayer()
                        .padding(20)
                }
                .environmentObject(playerModel)
                .clipShape(BubbleShape())
                .frame(width: WIDTH - 60, height: WIDTH - 60)
                .padding(.horizontal, 20)
                .edgesIgnoringSafeArea(.all)

                Button(action: sendBubble, label: {
                    HStack {
                        if !isLoading {
                            Image(systemName: "paperplane.fill")
                                .imageScale(.large)
                            Text("Send")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else {
                            ProgressView()
                        }

                    }.padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(.pink))
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.5 : 1)

                }).padding(.horizontal)

                Button(action: {
                    DispatchQueue.main.async {
                        isLoading = false
                        cameraManager.recordedVideoURL = nil
                    }
                }, label: {
                    HStack {
                        Image(systemName: "trash")
                            .imageScale(.large)
                        Text("Delete")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }.padding()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.gray)
                        .background(RoundedRectangle(cornerRadius: 25.0).stroke(.gray, lineWidth: 2))
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.5 : 1)
                }).padding(.horizontal)
            }
        } else {
            ProgressView()
        }
    }

    private func sendBubble() {
        guard let chat = selectedChat else {
            homeSettings.showAlert(title: "No recipient selected", message: "Select a recipient")
            return
        }

        guard let videoUrl = cameraManager.recordedVideoURL else {
            homeSettings.showAlert(title: "Internal camera error", message: "Please contact the app developer")
            return
        }

        homeSettings.showConfirmationAlert(title: "Confirm sending", message: "", okAction: initiate)

        func initiate() {
            isLoading = true

            Task {
                do {
                    try await SendPostUseCase(videoUrl: videoUrl,
                                              chat: chat,
                                              title: nil,
                                              description: nil,
                                              replyToId: nil,
                                              replyEntityType: nil,
                                              postType: .bubble)
                        .execute {
                            DispatchQueue.main.async {
                                isLoading = false
                                selectedChat = nil
                                cameraManager.recordedVideoURL = nil
                                dismiss()
                                cameraManager.recordedVideoURL = nil
                                if homeSettings.navigationPath.isEmpty {
                                    homeSettings.navigationPath.append(chat)
                                }
                            }
                        }
                } catch {
                    DispatchQueue.main.async {
                        isLoading = false
                        homeSettings.showAlert(title: "Send error", message: "\(error)")
                    }
                }
            }
        }
    }
}
