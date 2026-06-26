import SwiftUI

struct OTPTextField: View {
    @State private var otp1: String = ""
    @State private var otp2: String = ""
    @State private var otp3: String = ""
    @State private var otp4: String = ""

    // Manage focus for each field
    @FocusState private var focusedField: OTPField?

    @StateObject var viewModel: AuthViewModel
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        VStack {
            HStack(spacing: 15) {
                // First field
                OTPDigitTextField(text: $otp1)
                    .focused($focusedField, equals: .otp1)
                // Second field
                OTPDigitTextField(text: $otp2)
                    .focused($focusedField, equals: .otp2)
                // Third field
                OTPDigitTextField(text: $otp3)
                    .focused($focusedField, equals: .otp3)
                // Fourth field
                OTPDigitTextField(text: $otp4)
                    .focused($focusedField, equals: .otp4)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .onChange(of: otp1) {
                if otp1.count == 0 {
                    focusedField = nil // Hide the keyboard
                }
                if otp1.count == 1 {
                    focusedField = .otp2 // Move focus to the next field
                }
                viewModel.code = otp1 + otp2 + otp3 + otp4
            }
            .onChange(of: otp2) {
                if otp2.count == 0 {
                    focusedField = .otp1 // Hide the keyboard
                }
                if otp2.count == 1 {
                    focusedField = .otp3 // Move focus to the next field
                }
                viewModel.code = otp1 + otp2 + otp3 + otp4
            }
            .onChange(of: otp3) {
                if otp3.count == 0 {
                    focusedField = .otp2 // Hide the keyboard
                }
                if otp3.count == 1 {
                    focusedField = .otp4 // Move focus to the next field
                }
                viewModel.code = otp1 + otp2 + otp3 + otp4
            }
            .onChange(of: otp4) {
                if otp4.count == 0 {
                    focusedField = .otp3 // Hide the keyboard
                }
                if otp4.count == 1 {
                    focusedField = nil // Hide the keyboard
                }
                viewModel.code = otp1 + otp2 + otp3 + otp4
                verifyCode(viewModel: viewModel, appSettings: appSettings)
            }
            .onChange(of: viewModel.code) {
                if viewModel.code == "" {
                    otp1 = ""
                    otp2 = ""
                    otp3 = ""
                    otp4 = ""

                    focusedField = nil
                }
            }
        }
        .onAppear {
            focusedField = .otp1
        }
    }
}

// Custom field for entering a single digit
struct OTPDigitTextField: View {
    @Binding var text: String

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .frame(width: 50, height: 50)
            .multilineTextAlignment(.center)
            .font(.title)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.06), radius: 10)
            .onChange(of: text) {
                // Limit input to a single digit
                if text.count > 1 {
                    text = String(text.prefix(1))
                }
            }
    }
}

// Enum to manage field focus
enum OTPField: Hashable {
    case otp1, otp2, otp3, otp4
}
