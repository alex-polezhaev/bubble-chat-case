//
//  CameraRecorderView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 14.11.2024.
//

import Lottie
import SwiftUI

struct CameraRecorderView: View {
    @ObservedObject var cameraManager = CameraManager.shared

    var body: some View {
        VStack {
            VStack {
                if cameraManager.isConfigured && cameraManager.isRunning {
                    CameraLiveView()
                } else {
                    LottieView(animation: .named("skeleton-square"))
                        .playing(loopMode: .loop)
                }
            }.clipShape(BubbleShape())
                .frame(width: WIDTH - 60, height: WIDTH - 60)
                .padding(.horizontal, 20)
                .edgesIgnoringSafeArea(.all)

            Spacer().frame(height: 100)
                .onAppear {
                    CameraManager.shared.startSession()
                }
                .onDisappear {
                    CameraManager.shared.stopSession()
                }

            CameraActions()
        }
    }
}
