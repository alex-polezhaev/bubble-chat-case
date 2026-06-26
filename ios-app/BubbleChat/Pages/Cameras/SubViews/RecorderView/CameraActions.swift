//
//  CameraActions.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.09.2024.
//

import Foundation
import SwiftUI

struct CameraActions: View {
    @StateObject var cameraManager = CameraManager.shared

    @State private var timer: Timer?
    @State private var progress: CGFloat = 0

    var body: some View {
        HStack(spacing: 30) {
            Button {
                cameraManager.toggleFlash()
            } label: {
                Image(.cameraFlash)
                    .opacity(cameraManager.currentCameraPosition == .front ? 0.5 : 1)
            }
            .disabled(cameraManager.currentCameraPosition == .front)
            .padding(10)
            .offset(x: 5)
            .background(Circle().fill(.white))

            Button(action: {
                print("stop")
                stopTimer()
                cameraManager.stopRecording()
                progress = 0
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 88, height: 88)
                        .shadow(color: .black.opacity(0.12), radius: 10)

                    Circle()
                        .foregroundColor(.pink)
                        .frame(
                            width: progress == 0 ? 73 : 52,
                            height: progress == 0 ? 73 : 52
                        )

                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(lineWidth: 4)
                        .rotationEffect(Angle(degrees: -90))
                        .frame(width: 88, height: 88)
                        .foregroundColor(.pink)
                }
            }
            .frame(width: 80, height: 80)
            .hoverEffect(.lift)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.01)
                    .onEnded { _ in
                        print("start")
                        startTimer()
                        cameraManager.startRecording()
                    }
            )

            Button {
                cameraManager.switchCamera()
            } label: {
                Image(.cameraRotate)
            }.padding(10)
                .background(Circle().fill(.white))
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if progress >= 1 {
                stopTimer()
                cameraManager.stopRecording()
            } else {
                withAnimation {
                    progress += 0.00166
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        withAnimation {
            progress = 0
        }
    }
}
