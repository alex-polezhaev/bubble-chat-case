import SwiftUI

struct WritePostButton: View {
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            ZStack {
                Circle()
                    .fill(.white)
                Image(systemName: "text.bubble.fill")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.pink)
            }
        }
    }
}
