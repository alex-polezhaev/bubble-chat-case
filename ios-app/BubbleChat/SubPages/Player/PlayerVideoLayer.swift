//
//  PlayerVideoLayer.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 20.09.2024.
//

import AVFoundation
import AVKit
import Foundation
import SwiftUI

struct PlayerVideoLayer: View {
    @EnvironmentObject var playerModel: PlayerViewModel

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            CameraPlayerUiKitController(player: playerModel.player, size: size)
        }
    }
}

struct CameraPlayerUiKitController: UIViewControllerRepresentable {
    var player: AVPlayer
    var size: CGSize

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill

        // Disable interaction
        viewController.view.isUserInteractionEnabled = false
        viewController.view.layer.addSublayer(playerLayer)

        context.coordinator.playerLayer = playerLayer

        return viewController
    }

    func updateUIViewController(_: UIViewController, context: Context) {
        if context.coordinator.playerLayer?.player !== player {
            context.coordinator.playerLayer?.player = player
        }
        // Update the layer size
        context.coordinator.playerLayer?.frame = CGRect(origin: .zero, size: size)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
