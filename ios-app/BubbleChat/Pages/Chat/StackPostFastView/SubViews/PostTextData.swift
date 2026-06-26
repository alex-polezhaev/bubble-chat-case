import SwiftUI

struct PostTextData: View {
    var title: String?
    var description: String?

    var body: some View {
        VStack(spacing: 0) {
            if let title = title {
                Text(title)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
            }

            if let description = description {
                Text(description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
            }
        }
    }
}
