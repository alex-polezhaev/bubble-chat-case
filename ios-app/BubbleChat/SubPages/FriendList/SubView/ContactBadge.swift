import Kingfisher
import SwiftUI

struct ContactBadge: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var activityModel: ContactActivityViewModel

    init(buttonTitle: String, contact: Contact, onButtonTapped: @escaping () -> Void) {
        _activityModel = StateObject(wrappedValue: ContactActivityViewModel(contact: contact))
        self.onButtonTapped = onButtonTapped
        self.buttonTitle = buttonTitle
        self.contact = contact
    }

    var contact: Contact
    var buttonTitle: String

    var onButtonTapped: () -> Void

    var body: some View {
        HStack {
            if let title = activityModel.title {
                KFImage(URL(string: HOST + (activityModel.avatar ?? "")))
                    .placeholder {
                        ZStack {
                            Circle()
                                .fill(.black.opacity(0.1))
                            Text(getAvatarString(from: title))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black.opacity(0.5))
                        }.frame(width: 48, height: 48)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .frame(width: 48)
            }

            VStack(alignment: .leading) {
                Text(activityModel.title ?? "")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                if activityModel.lastActiveAt != nil {
                    Text("Already on Bubble Chat ❤️")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.gray)
                }

                if let status = activityModel.status {
                    Text(status.rawValue)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(status == .online ? .pink : .black)
                }
            }
            Spacer()
            Button {
                onButtonTapped()
            } label: {
                Text(buttonTitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(true ? .white : .pink)
                    .padding()
                    .background(
                        Capsule().fill(.pink)
                    )
            }
        }
    }
}
