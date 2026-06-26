import Foundation

// MARK: - First name validation

extension String {
    func isValidFistName() -> Bool {
        let length = count
        if length < 3 { return false }
        return true
    }
}

// MARK: - Last name validation

extension String {
    func isValidLastName() -> Bool {
        let length = count
        if length < 1 { return false }
        return true
    }
}

// MARK: - Phone validation

extension String {
    // Check for compliance with the international phone format
    func isValidInternationalPhoneNumber() -> Bool {
        // Regular expression for an international phone number
        let phoneRegex = "^\u{002B}[1-9]\\d{1,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}

extension String {
    func formattedPhoneNumber() -> String {
        let digits = filter { $0.isNumber }
        if digits.hasPrefix("7") {
            return "+\(digits)"
        } else {
            return "+7\(digits)"
        }
    }
}

extension String {
    func isValidPhoneNumber() -> Bool {
        // Remove all characters except digits
        let digits = filter { $0.isNumber }

        // Check whether the string starts with "7" and consists of 11 digits
        if digits.count == 11 {
            return true
        }

        return false
    }
}
