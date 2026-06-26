//
//  LastNameTextField.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import SwiftUI

struct LastNameTextField: View {
    @StateObject var viewModel: AuthViewModel
    @State var focusedField: FocusState<FocusField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Last name")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(viewModel.errorLastName ? .red : .black)

            TextField("Type name", text: $viewModel.lastName)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .focused(focusedField, equals: .lastName)
                .submitLabel(.continue)
                .onSubmit {
                    focusedField.wrappedValue = .code
                }
                .onChange(of: viewModel.lastName) {
                    viewModel.clearError()
                    viewModel.lastName = viewModel.lastName.replacingOccurrences(of: " ", with: "")
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(.white)
            .strokeBorder(viewModel.errorLastName ? .red : .white, lineWidth: 1)
            .shadow(color: Color.black.opacity(0.05), radius: 10))
        .onTapGesture {
            focusedField.wrappedValue = .lastName
        }
    }
}
