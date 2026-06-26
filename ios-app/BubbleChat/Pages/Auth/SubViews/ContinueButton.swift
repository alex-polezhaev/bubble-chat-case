//
//  ContinueButton.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import SwiftUI

struct ContinueButton: View {
    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        Button(action: {
            switch viewModel.authStage {
            case .enterPhone:
                validatePhoneAndMove(viewModel: viewModel)
            case .enterName:
                sendCode(viewModel: viewModel)
            case .enterOtp:
                verifyCode(viewModel: viewModel, appSettings: appSettings)
            }

        }) {
            VStack {
                if viewModel.loading {
                    ProgressView()
                } else {
                    Text("Continue")
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .padding()
            .frame(maxWidth: .infinity)
            .background(UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            ).fill(viewModel.loading ? .gray.opacity(0.1) : .pink))
        }.disabled(viewModel.loading)
    }
}
