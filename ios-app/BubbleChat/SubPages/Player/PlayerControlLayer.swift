//
//  PlayerControlLayer.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 20.09.2024.
//

import AVFoundation
import Foundation
import SwiftUI

struct PlayerControlLayer: View {
    @EnvironmentObject var playerModel: PlayerViewModel

    var body: some View {
        ZStack {
            // Playback progress
            BubbleShape()
                .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

            // Progress indicator
            BubbleShape()
                .trim(from: 0, to: playerModel.progress)
                .stroke(.ultraThinMaterial, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.init(degrees: 90))

            // Visible circle
            BubbleShape()
                .trim(from: playerModel.progress, to: playerModel.progress + 0.00001)
                .stroke(.regularMaterial, style: StrokeStyle(lineWidth: 28, lineCap: .round))
                .rotationEffect(.init(degrees: 90))

            // Draggable circle
            Circle()
                .fill(Color.white.opacity(0.00001))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle().size(CGSize(width: 60, height: 60)))
                .offset(x: (UIScreen.main.bounds.width - 100) / 2)
                .rotationEffect(.init(degrees: 360 * playerModel.progress))
                .gesture(DragGesture()
                    .onChanged(playerModel.onDrag(value:))
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            playerModel.player.play()
                            playerModel.isPlaying = true
                        }
                    }
                )
                .rotationEffect(.init(degrees: -90))

            // Play/Pause button
            Button(action: {
                playerModel.togglePlayPause()
            }) {
                Image(systemName: playerModel.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.gray.opacity(0.3))
            }.animation(nil, value: playerModel.isPlaying)
        }
    }
}
