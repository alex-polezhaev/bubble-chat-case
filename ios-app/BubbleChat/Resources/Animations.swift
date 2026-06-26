//
//  Animations.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 18.12.2024.
//

import SwiftUI

extension AnyTransition {
    static var customScaleTransition: AnyTransition {
        AnyTransition.scale(scale: 1.4).combined(with: .opacity)
    }
}

/////
/////
///
///
extension View {
    func animatedScaleOnAppear(
        duration: Double = 0.3,
        delay: Double = 0,
        scaleUp: CGFloat = 1.1,
        scaleDown: CGFloat = 1.0
    ) -> some View {
        modifier(ScaleOnAppearWithResetModifier(duration: duration, delay: delay, scaleUp: scaleUp, scaleDown: scaleDown))
    }
}

struct ScaleOnAppearWithResetModifier: ViewModifier {
    let duration: Double
    let delay: Double
    let scaleUp: CGFloat
    let scaleDown: CGFloat

    @State private var isScaledUp = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isScaledUp ? scaleUp : scaleDown)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).delay(delay)) {
                    isScaledUp = true
                }

                // Restore the scale after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) {
                    withAnimation(.easeInOut(duration: duration)) {
                        isScaledUp = false
                    }
                }
            }
    }
}
