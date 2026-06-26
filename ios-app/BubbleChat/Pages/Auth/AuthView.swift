//
//  AuthView.swift
//  LoginPage
//
//  Created by polezhaev_aleksandr on 09.08.2024.
//

import Combine
import SwiftUI

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()

    var body: some View {
        VStack {
            ZStack {
                Image("AuthBackgroud")
                    .resizable()
                    .scaledToFill()
                    .frame(height: HEIGHT * 0.25)
                    .clipped() // Clips the image if it goes beyond the bounds

                Image("AuthLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .offset(y: 30)
            }
            .frame(maxWidth: .infinity) // Stretch to full width

            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: 70,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(.white)
                .shadow(radius: 20)

                VStack {
                    FormView()
                    Spacer()
                }
                .padding(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.pink)
        .ignoresSafeArea()
        .hideKeyboardOnTapOrSwipe()
        .environmentObject(viewModel)
    }
}
