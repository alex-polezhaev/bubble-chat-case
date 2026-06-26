//
//  CameraVideoPreview.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import Alamofire
import AVFoundation
import AVKit
import Foundation
import SwiftData
import SwiftUI
import SwiftyJSON

enum CameraPreviewPageType {
    case chat, menu
}

struct CameraVideoPreview: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var homeSettings: HomeSettings
    @Environment(\.dismiss) var dismiss

    @StateObject var playerModel: CustomPlayerViewModel

    @Binding var selectedDialogue: Dialogue?

    @State var isLoading: Bool = false
    var pageType: CameraPreviewPageType

    var videoURL: URL

    let cameraManager = CameraManager.shared

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if playerModel.isLoading {
                    SkeletonCameraView()
                } else {
                    PlayerVideoLayer(player: playerModel.player)
                    PlayerControlLayer(viewModel: playerModel).padding(20)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 90, style: .continuous))
                .frame(height: WIDTH - 60)
                .onAppear {
                    print("appear1")
                }

            Spacer().frame(height: 30)

            Button {
                cameraManager.recordedVideoURL = nil
            } label: {
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
            }

            Button {
                if let dialogue = selectedDialogue {
                    Task {
                        isLoading = true
                        let sended = await sendVideo(previewURL: videoURL, dialogue: dialogue, modelContext: modelContext)
                        if sended {
                            cameraManager.recordedVideoURL = nil

                            if pageType == .chat {
                                cameraManager.recordedVideoURL = nil
                                dismiss()
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            }
                            if pageType == .menu {
                                homeSettings.selectedTab = .home
                                homeSettings.navigationPath.append(dialogue)
                                selectedDialogue = nil
                            }

                        } else {
                            homeSettings.showAlert(title: "Error", message: "Error while sending the video")
                        }
                        isLoading = false
                    }

                } else {
                    homeSettings.showAlert(title: "Error", message: "Select a recipient")
                }
            } label: {
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
            }
        }.frame(width: WIDTH - 60)
    }
}
