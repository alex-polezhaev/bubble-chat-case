//
//  NoChats.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 10.10.2024.
//

import SwiftUI

struct NoChats: View {
    @EnvironmentObject var homeSettings: HomeSettings
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image("empty-state-logo")
                .resizable()
                .frame(width: 80, height: 80)
            Text("You haven't bubbles yet!")
                .font(.system(size: 20, weight: .medium, design: .rounded))
            Button {
                homeSettings.showFiendList = true
            } label: {
                Text("Let's start")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .padding()
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.pink)
                    )
            }
        }.padding(.top, 80)
    }
}
