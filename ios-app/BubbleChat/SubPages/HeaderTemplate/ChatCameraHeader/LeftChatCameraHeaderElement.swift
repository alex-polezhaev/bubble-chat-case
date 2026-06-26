//
//  LeftChatCameraHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct LeftChatCameraHeaderElement: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button(action: {
            dismiss()
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }) {
            ZStack {
                Circle().fill(.white)
                Image(systemName: "chevron.left")
                    .fontWeight(.bold)
                    .font(.system(size: 11))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)

            }.frame(width: 48, height: 48)
        }
    }
}
