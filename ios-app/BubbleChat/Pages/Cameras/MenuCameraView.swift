//
//  MenuCameraView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import AVFoundation
import Foundation
import SwiftUI

struct MenuCameraView: View {
    @EnvironmentObject var homeSettings: HomeSettings
    @ObservedObject var cameraManager = CameraManager.shared
    @StateObject var viewModel: CameraMenuViewModel

    @State var showSelectSheet: Bool = false

    init() {
        _viewModel = StateObject(wrappedValue: CameraMenuViewModel())
    }

    var body: some View {
        if homeSettings.selectedTab == .camera {
            ZStack(alignment: .bottom) {
                ZStack {
                    if let videoUrl = cameraManager.recordedVideoURL {
                        CameraPreviewView(videoUrl: videoUrl, selectedChat: $viewModel.selectedChat)

                    } else {
                        CameraRecorderView()
                    }

                    HeaderTemplate(leftElement: LeftMenuCameraHeaderElement(), centerElement: CenterMenuCameraHeaderElement(selectedChat: $viewModel.selectedChat, showSelectSheet: $showSelectSheet), rightElement: Spacer())
                }
            }

            .background(Color.background).ignoresSafeArea()
            .sheet(isPresented: $showSelectSheet) {
                ReceiverListView(selectedChat: $viewModel.selectedChat)
            }

            .environmentObject(viewModel)
        }
    }
}
