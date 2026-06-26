import AudioToolbox
import SwiftUI

struct LongPressTest: View {
    @State private var showPanel = false

    var body: some View {
        ZStack {
            // Main content
            VStack {
                Text("Long press")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .onLongPressGesture {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()

                        withAnimation(.bouncy(duration: 0.3)) {
                            showPanel = true
                            AudioServicesPlaySystemSound(1104)
                        }
                    }
            }

            // Additional panel
            if showPanel {
                RoundedRectangle(cornerRadius: 34)
                    .background(.ultraThinMaterial)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.3)) {
                            showPanel = false
                        }
                    }
            }
        }
    }
}
