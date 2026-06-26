import SwiftUI

struct PhoneNumberTextField: View {
    @StateObject var viewModel: AuthViewModel
    @State var focusedField: FocusState<FocusField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Phone number")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(viewModel.errorPhoneNumber ? .red : .black)

            TextField("Type phone", text: $viewModel.phoneNumber)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .keyboardType(.numberPad)
                .focused(focusedField, equals: .phone)
                .submitLabel(.continue)
                .onSubmit {
                    focusedField.wrappedValue = .lastName
                }
                .onChange(of: viewModel.phoneNumber) {
                    viewModel.phoneNumber = formatPhoneNumber(viewModel.phoneNumber)
                    viewModel.clearError()
                }
                .onAppear {
                    focusedField.wrappedValue = .phone
                }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(.white)
            .strokeBorder(viewModel.errorPhoneNumber ? .red : .white, lineWidth: 1)
            .shadow(color: Color.black.opacity(0.05), radius: 10))
        .onTapGesture {
            focusedField.wrappedValue = .phone
        }
    }
}
