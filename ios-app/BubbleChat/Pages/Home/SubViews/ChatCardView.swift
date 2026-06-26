import Kingfisher
import SwiftUI

struct ChatCardView: View {
    @StateObject private var viewModel: ChatActivityViewModel

    private var chat: Chat

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatActivityViewModel(chat: chat))
    }

    var body: some View {
        NavigationLink(
            destination: ChatView(chat: chat, activityModel: viewModel)
                .navigationBarBackButtonHidden(),
            label: {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                if let picture = viewModel.picture {
                                    KFImage(URL(string: HOST + picture))
                                        .placeholder {
                                            ProfilePhotoPlaceholder(string: viewModel.title ?? "")
                                            Color.gray
                                        }
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(22)
                                }

                                if let lastChatActivityAt = viewModel.lastChatActivityAt {
                                    Text(lastChatActivityAt, style: .time)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.gray)
                                }
                            }

                            Text(viewModel.title ?? "")
                                .lineLimit(2)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .frame(maxHeight: .infinity, alignment: .top)
                        }

                        Spacer()

                        RoundedRectangle(cornerRadius: 22)
                            //                            .resizable()
                            //                            .scaledToFit()
                            .fill(.gray.opacity(0.2))
                            .frame(width: 68, height: 68)
                            .cornerRadius(22)
                            .overlay {
                                Text("0:00")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .padding(4)
                                    .foregroundStyle(.gray)
                                    .background(Capsule().background(
                                        .ultraThinMaterial
                                    ))
                            }
                    }

                    if let status = viewModel.userStatus {
                        let isOnline = status == .online

                        Text(status.rawValue)
                            .lineLimit(1)
                            .font(.system(size: 14, weight: isOnline ? .bold : .medium, design: .rounded))
                            .foregroundStyle(isOnline ? .pink : .gray)
                            .padding(.vertical, 4)
                    }

                    if let title = viewModel.postTitle {
                        Text(title)
                            .lineLimit(1)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.vertical, 4)
                    }

                    if let decription = viewModel.description {
                        Text(decription)
                            .lineLimit(3)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.gray)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.leading, 4)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.white)
                )
            }
        )
        .buttonStyle(.plain)
        .environmentObject(viewModel)
    }
}
