//
//  AuthViewModel.swift
//  LoginPage
//
//  Created by polezhaev_aleksandr on 09.08.2024.
//

import Alamofire
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var authStage: AuthStages = .enterPhone

    enum AuthStages {
        case enterPhone, enterName, enterOtp
    }

    @Published var phoneNumber: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var code: String = ""

    @Published var loading: Bool = false

    @Published var errorPhoneNumber: Bool = false
    @Published var errorFirstName: Bool = false
    @Published var errorLastName: Bool = false
    @Published var errorCode: Bool = false

    @Published var errorMsg: String = ""

    @Published var currentUser: PublicUser?

    func clearError() {
        withAnimation(.snappy) {
            self.errorPhoneNumber = false
            self.errorFirstName = false
            self.errorLastName = false
            self.errorCode = false
            self.errorMsg = ""
        }
    }
}
