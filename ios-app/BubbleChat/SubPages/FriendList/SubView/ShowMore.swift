import SwiftUI

struct ShowMore: View {
    var body: some View {
        HStack {
            Rectangle().opacity(0.1).frame(height: 1)

            Text("Show more")
                .padding(12)
                .foregroundStyle(.pink)
                .background(
                    Capsule().fill(.pink.opacity(0.1))
                )
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Rectangle().opacity(0.1).frame(height: 1)
        }
    }
}
