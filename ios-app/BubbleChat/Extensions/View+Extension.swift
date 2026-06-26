//
//  View+Extension.swift
//  LoginPage
//
//  Created by polezhaev_aleksandr on 11.08.2024.
//

import Combine
import Foundation
import SwiftUI
import UIKit

// Modifier to hide the keyboard on tap or swipe
struct HideKeyboardOnTapOrSwipe: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture().onChanged { _ in
                hideKeyboard()
            })
            .onTapGesture {
                hideKeyboard()
            }
    }

    // Function to hide the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    // Convenience method for using the modifier
    func hideKeyboardOnTapOrSwipe() -> some View {
        modifier(HideKeyboardOnTapOrSwipe())
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

class KeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }

        willShow
            .merge(with: willHide)
            .assign(to: \.isKeyboardVisible, on: self)
            .store(in: &cancellableSet)
    }
}
