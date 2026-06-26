//
//  parsePhoneNumber.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 06.10.2024.
//

import PhoneNumberKit

func parsePhoneNumber(_ number: String) -> String? {
    let phoneNumberUtility = PhoneNumberUtility()

    do {
        let phoneNumber = try phoneNumberUtility.parse(number)
        return phoneNumberUtility.format(phoneNumber, toType: .e164)

    } catch {
//        print("Phone number parser error")
//        print(number)
        return nil
    }
}
