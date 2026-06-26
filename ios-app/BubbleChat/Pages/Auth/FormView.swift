//
//  FormView.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import Combine
import SwiftUI

enum FocusField: Int, CaseIterable {
    case phone, firstName, lastName, code
}

struct FormView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @FocusState var focusedField: FocusField?

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                switch viewModel.authStage {
                case .enterPhone:
                    Text("Enter your phone number")
                        .transition(.identity)
                case .enterName:
                    HStack {
                        Button {
                            viewModel.authStage = .enterPhone
                        } label: {
                            Image(systemName: "arrowshape.backward")
                        }.padding(.trailing)

                        Text("Whats your name?")

                    }.transition(.identity)
                case .enterOtp:
                    VStack {
                        Text("Enter last 4 digits from called number")
                            .multilineTextAlignment(.center)

                        Text("X-(XXX)-XXX-1234")
                            .padding(.top, 6)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }.transition(.identity)
                }
            }
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .opacity(0.8)
            .padding(.vertical)

            switch viewModel.authStage {
            case .enterPhone:
                PhoneNumberTextField(viewModel: viewModel, focusedField: $focusedField)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .enterName:
                VStack {
                    FirstNameTextField(viewModel: viewModel, focusedField: $focusedField)
                    LastNameTextField(viewModel: viewModel, focusedField: $focusedField)
//                        Button("first") {
//                            viewModel.firstName = "aaa"
//                            viewModel.lastName = "a"
//                        }
//                        Button("second") {
//                            viewModel.firstName = "bbb"
//                            viewModel.lastName = "b"
//                        }
                }.transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .enterOtp:
                OTPTextField(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }

            ErrorPlate(viewModel: viewModel)
            ContinueButton(viewModel: viewModel)

        }.animation(.easeInOut(duration: 0.4), value: viewModel.authStage)
    }
}
