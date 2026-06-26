//
//  ChatCameraView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

struct ChatCameraView: View {
    @ObservedObject var cameraManager = CameraManager.shared

    @State var chat: Chat?

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                if let videoUrl = cameraManager.recordedVideoURL {
                    CameraPreviewView(videoUrl: videoUrl, selectedChat: $chat)
                } else {
                    CameraRecorderView()
                }

                HeaderTemplate(leftElement: LeftChatCameraHeaderElement(), centerElement: CenterChatCameraHeaderElement(), rightElement: Spacer())
            }
        }
        .background(Color.background).ignoresSafeArea()
    }
}
