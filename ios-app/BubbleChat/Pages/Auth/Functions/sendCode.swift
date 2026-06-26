import Alamofire
import Foundation

// Function to send the code
func sendCode(viewModel: AuthViewModel) {
    // Check that the fields are not empty
    guard viewModel.firstName.isValidFistName()
    else {
        viewModel.errorFirstName = true
        viewModel.errorMsg = "Invalid first name"
        return
    }

    guard viewModel.lastName.isValidLastName()
    else {
        viewModel.errorLastName = true
        viewModel.errorMsg = "Invalid last name"
        return
    }

    guard let phoneNumber = parsePhoneNumber(viewModel.phoneNumber) else {
        viewModel.errorPhoneNumber = true
        viewModel.errorMsg = "Invalid phone number"
        return
    }

    // Prepare the data to send
    let parameters: [String: String] = [
        "firstName": viewModel.firstName,
        "lastName": viewModel.lastName,
        "phone": phoneNumber,
    ]

    // Set the loading state
    viewModel.loading = true

    // Alamofire request with response decoding
    AF.request("\(HOST)/auth/send_code", method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: PublicUser.self) { response in
            // Stop loading
            viewModel.loading = false

            switch response.result {
            case let .success(publicUser):
                print("Code successfully sent! User info: \(publicUser)")
                viewModel.authStage = .enterOtp
                // Handle publicUser, e.g., store it in the viewModel
                viewModel.currentUser = publicUser
            case let .failure(error):
                // Handle the request error
                viewModel.errorMsg = error.localizedDescription
                print("Failed to send code: \(error)")
            }
        }
}
