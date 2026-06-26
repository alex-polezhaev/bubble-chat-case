//
//  UINavigationController+Extension.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 05.10.2024.
//

import Foundation
import UIKit

// Disables the back button when .navigationBarBackButtonHidden() is set, but keeps the swipe gesture
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
