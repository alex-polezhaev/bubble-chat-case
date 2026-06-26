//
//  CameraLiveView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 20.10.2024.
//

import AVFoundation
import SwiftUI

struct CameraLiveView: UIViewControllerRepresentable {
    class CameraViewController: UIViewController {
        private var previewLayer: AVCaptureVideoPreviewLayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            setupPreviewLayer()
        }

        // Setup the preview layer for the camera from CameraManager
        private func setupPreviewLayer() {
            // Make sure the preview layer is available
            guard let layer = CameraManager.shared.previewLayer else {
                print("Preview layer not available")
                return
            }

            previewLayer = layer
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            view.layer.addSublayer(previewLayer!)
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            previewLayer?.frame = view.bounds
        }
    }

    func makeUIViewController(context _: Context) -> CameraViewController {
        let viewController = CameraViewController()
        return viewController
    }

    func updateUIViewController(_: CameraViewController, context _: Context) {
        // Update the view controller when necessary
    }
}
