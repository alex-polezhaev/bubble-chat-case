//
//  PlayerViewModel.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 22.09.2024.
//

import AVFoundation
import Foundation
import SwiftUI

class PlayerViewModel: NSObject, ObservableObject {
    @Published var progress: CGFloat = 0 // Video playback progress
    @Published var isPlaying: Bool = false // play/pause state
    @Published var isLoading: Bool = true // Loading indicator
    @Published var cornerOffset: CGFloat = 0 // Corner offset while dragging

    private var playerTimeObserver: Any?
    private var playerEndObserver: NSObjectProtocol?
    @Published var player: AVPlayer

    init(videoUrl: URL) {
        player = AVPlayer(url: videoUrl)
        super.init()
        setupPlayerObservers()

        print("INIT")
    }

    // Add observers for the player state
    private func setupPlayerObservers() {
        // Observe the player's ready-to-play status
        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        player.currentItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new, .initial], context: nil)

        // Observe the end of the video
        playerEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.restartVideo()
        }

        // Observe playback progress
        let interval = CMTime(seconds: 0.01, preferredTimescale: 1000)
        playerTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateProgress(currentTime: time)
        }
    }

    // Update playback progress
    private func updateProgress(currentTime: CMTime) {
        let currentSeconds = CMTimeGetSeconds(currentTime)
        let totalSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)

        if totalSeconds > 0 {
            progress = CGFloat(currentSeconds / totalSeconds)
        }
    }

    // Restart the video after it finishes
    private func restartVideo() {
        player.seek(to: .zero)
//        player.play()
//        isPlaying = true
    }

    // Play/Pause
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    // Play/Pause
    func play() {
        isPlaying = true
        player.play()
    }

    func pause() {
        isPlaying = false
        player.pause()
    }

    // Method to handle dragging and angle changes
    func onDrag(value: DragGesture.Value) {
        // Calculate the rotation angle
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 0, vector.dx - 0)
        var angle = radians * 180 / .pi
        if angle < 0 { angle = 360 + angle }

        // Calculate progress and set the seek position on the player
        let totalDuration = CMTimeGetSeconds(player.currentItem?.duration ?? .zero)
        if totalDuration > 0 {
            let targetTime = CMTime(seconds: totalDuration * (angle / 360), preferredTimescale: 600)

            progress = CGFloat(angle / 360)

            player.pause() // Pause playback during seeking
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    // Remove observers on deinitialization and reset the player
    deinit {
        if let playerTimeObserver = playerTimeObserver {
            player.removeTimeObserver(playerTimeObserver)
        }
        if let playerEndObserver = playerEndObserver {
            NotificationCenter.default.removeObserver(playerEndObserver)
        }

        // Clear observers for the current player item
        player.currentItem?.removeObserver(self, forKeyPath: "status")
        player.currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")

        // Stop playback and reset the player
        player.pause()
        player.replaceCurrentItem(with: nil)

        print("deinit")
    }

    // Handle player state updates
    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == "status", player.currentItem?.status == .readyToPlay {
            isLoading = false
            // Remove automatic playback
            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //     self.player.play()
            //     self.isPlaying = true
            // }
        }
    }
}
