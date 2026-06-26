//
//  formatPhoneNumber.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.10.2024.
//

// Function to format a phone number
func formatPhoneNumber(_ number: String) -> String {
    let cleanedNumber = number.filter { "0123456789".contains($0) } // Remove everything except digits

    var formattedString = ""
    let mask = "+X (XXX) XXX-XXXX" // Phone number mask

    var index = cleanedNumber.startIndex
    for ch in mask where index < cleanedNumber.endIndex {
        if ch == "X" {
            formattedString.append(cleanedNumber[index])
            index = cleanedNumber.index(after: index)
        } else {
            formattedString.append(ch)
        }
    }

    return formattedString
}
