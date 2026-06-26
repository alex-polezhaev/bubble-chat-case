//
//  validatePhoneAndMove.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

func validatePhoneAndMove(viewModel: AuthViewModel) {
    guard viewModel.phoneNumber.isValidPhoneNumber() else {
        viewModel.errorPhoneNumber = true
        viewModel.errorMsg = "Invalid phone number format"
        return
    }

    viewModel.authStage = .enterName
}

// func validatePhoneAndMove(viewModel: AuthViewModel) {
//    guard viewModel.phoneNumber.isValidPhoneNumber(), let phone = parsePhoneNumber(viewModel.phoneNumber) else {
//        viewModel.errorPhoneNumber = true
//        viewModel.errorMsg = "Invalid phone number format"
//        return
//    }
//
//
//
//    // Prepare the data to send
//    let parameters: [String: String] = [
//        "phone": phone
//    ]
//
//    // Set the loading state
//    viewModel.loading = true
//
//    // Alamofire request to check whether the phone is registered
//    AF.request("\(HOST)/auth/check_phone", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
//        .validate(statusCode: 200 ..< 300)
//        .responseDecodable(of: PublicUser.self) { response in
//            // Stop loading
//            viewModel.loading = false
//
//            switch response.result {
//                case .success(let publicUser):
//                    print("Phone number is registered")
//
//                    viewModel.authStage = .enterOtp // Or another stage
//                    viewModel.currentUser = publicUser
//                case .failure(let error):
//                    if response.response?.statusCode == 400 {
//                        // Handle the case where the number is not registered
//                        viewModel.authStage = .enterName
//                    } else {
//                        // Handle other errors
//                        viewModel.errorMsg = error
//                    }
//            }
//        }
// }
