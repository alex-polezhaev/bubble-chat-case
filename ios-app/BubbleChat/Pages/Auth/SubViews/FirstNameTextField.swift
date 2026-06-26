//
//  FirstNameTextField.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import SwiftUI

struct FirstNameTextField: View {
    @StateObject var viewModel: AuthViewModel
    @State var focusedField: FocusState<FocusField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("First name")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(viewModel.errorFirstName ? .red : .black)

            TextField("Type name", text: $viewModel.firstName)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .focused(focusedField, equals: .firstName)
                .submitLabel(.continue)
                .onSubmit {
                    focusedField.wrappedValue = .lastName
                }
                .onAppear {
                    focusedField.wrappedValue = .firstName
                }
                .onChange(of: viewModel.firstName) {
                    viewModel.clearError()
                    viewModel.firstName = viewModel.firstName.replacingOccurrences(of: " ", with: "")
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(.white)
            .strokeBorder(viewModel.errorFirstName ? .red : .white, lineWidth: 1)
            .shadow(color: Color.black.opacity(0.05), radius: 10))
        .onTapGesture {
            focusedField.wrappedValue = .firstName
        }
    }
}
