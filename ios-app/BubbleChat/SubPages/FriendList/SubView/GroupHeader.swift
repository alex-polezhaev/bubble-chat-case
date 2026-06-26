import SwiftUI

struct GroupHeader: View {
    var title: String
    var counter: Int

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            Text("\(counter)")
        }.padding(.vertical, 10)
    }
}
