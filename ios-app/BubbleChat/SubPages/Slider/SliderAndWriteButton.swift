import SwiftUI

struct SliderAndWriteButton: View {
    var onSlide: (() -> Void)?
    var onClick: (() -> Void)?

    var body: some View {
        HStack {
            SliderControlPanel(slideTitle: "Swipe to record") {
                onSlide?()
            }.padding(.horizontal)
            WritePostButton {
                onClick?()
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 0)
        .frame(height: 68)
        .padding()
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
