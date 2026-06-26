//
//  PostBackground.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.12.2024.
//
import SwiftUI

struct PostBackground: View {
    private var rectangle: UnevenRoundedRectangle

    init(postType: PostType, isMine: Bool) {
        var topCornerRadius: CGFloat {
            switch postType {
            case .bubble:
                return 90
            case .frame:
                return 90
            case .topic:
                return 25
            }
        }

        let bottomLeadingRadius: CGFloat = isMine ? 25 : 0
        let bottomTrailingRadius: CGFloat = isMine ? 0 : 25

        rectangle = UnevenRoundedRectangle(
            topLeadingRadius: topCornerRadius,
            bottomLeadingRadius: bottomLeadingRadius,
            bottomTrailingRadius: bottomTrailingRadius,
            topTrailingRadius: topCornerRadius
        )
    }

    var body: some View {
        rectangle
            .fill(.white)
            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 0)
            .overlay {
                rectangle
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: 0.5)
                    .padding(1)
            }
    }
}
