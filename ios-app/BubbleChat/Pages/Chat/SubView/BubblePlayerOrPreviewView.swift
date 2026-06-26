//
//  BubblePlayerOrPreviewView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 17.11.2024.
//

import Lottie
import SwiftUI

struct BubblePlayerOrPreviewView: View {
//    @EnvironmentObject var bubbleModel: BubbleViewModel

    var size: BubbleSize
    var controlable: Bool

    enum BubbleSize {
        case small, medium, large
    }

    var body: some View {
        VStack {
//            if let playerModel = bubbleModel.playerModel {
//                PlayerEntrypoint(controlable: self.controlable)
//                    .environmentObject(playerModel)
//            } else if let previewModel = bubbleModel.previewModel {
//                PreviewEntrypoint(previewModel: previewModel)
//            } else {
//                LottieView(animation: .named("skeleton-square"))
//                    .playing(loopMode: .loop)
//            }
        }
        .aspectRatio(contentMode: .fit)
        .clipShape(BubbleShape())
        .frame(maxWidth: getWidth())
    }

    func getWidth() -> CGFloat {
        switch size {
        case .small:
            WIDTH * 0.25
        case .medium:
            WIDTH * 0.65
        case .large:
            WIDTH * 0.85
        }
    }
}
