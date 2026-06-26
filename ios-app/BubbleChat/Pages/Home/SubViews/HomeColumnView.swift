//
//  HomeColumnView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.11.2024.
//

import SwiftUI

struct HomeColumnView: View {
    @EnvironmentObject var homeSettings: HomeSettings

    let chats: [Chat]

    var body: some View {
        LazyVStack {
            ForEach(chats, id: \.self) { chat in
                ChatCardView(chat: chat)
                    .animatedScaleOnAppear()
            }

            if chats.count < 2 {
                Button {
                    homeSettings.showFiendList = true
                } label: {
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            Color.gray.opacity(0.2),
                            style: StrokeStyle(
                                lineWidth: 2, // Line width
                                lineCap: .round, // Stroke cap (e.g., .round or .butt)
                                dash: [10, 5] // Dash and gap length
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .padding(2)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 25, weight: .medium, design: .rounded))
                                .foregroundStyle(.gray.opacity(0.2))
                        }
                }
            }
        }
    }
}
