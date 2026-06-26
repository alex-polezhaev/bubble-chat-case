//
//  ProfileView.swift
//  BubblePages
//
//  Created by polezhaev_aleksandr on 28.06.2024.
//

import Foundation
import Kingfisher
import Lottie
import SwiftUI

struct ProfileBio: View {
    let currentUser = UserManager.shared.getCurrentUser()

    var body: some View {
        VStack {
            VStack {
                if let avatar = currentUser.avatar {
                    KFImage(URL(string: HOST + avatar))
                        .placeholder {
                            ProfilePhotoPlaceholder(string: currentUser.firstName + currentUser.lastName)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                } else {
                    ProfilePhotoPlaceholder(string: currentUser.firstName + currentUser.lastName)
                }
            }
            .clipShape(Circle())
            .frame(width: 96, height: 96)
            .padding(.top, 15)

            Text("\(currentUser.firstName) \(currentUser.lastName)")
                .font(.system(size: 32))
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .padding(.top, 10)
                .multilineTextAlignment(.center)
        }
    }
}

struct ProfileGroupTitle: View {
    var groupTitle: String

    var body: some View {
        VStack {
            Text(groupTitle)
                .foregroundStyle(.lightGrayText)
                .fontDesign(.rounded)
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 20)
        }
    }
}

struct ProfileButtonEntrails: View {
    var title: String
    var iconId: String

    var action: (() -> Void)?

    var body: some View {
        Button(action: {
            if let action = action {
                action()
            }

        }, label: {
            HStack {
                Image(systemName: iconId)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 18))
                    .frame(width: 28, height: 18)
                Text(title)
                    .fontDesign(.rounded)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .fontWeight(.bold)
                    .font(.system(size: 12))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
            }.padding(.horizontal, 18)
                .padding(.vertical, 11)
        }).buttonStyle(PlainButtonStyle())
    }
}

struct ProfileButton: Identifiable {
    var id = UUID()

    var title: String
    var iconId: String

    var action: (() -> Void)?
}

struct ProfileButtonsGroup: View {
    var ButtonsData: [ProfileButton]

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/,
                style: .continuous
            )
            .fill(.white)
            .padding(0)
            VStack {
                ForEach(ButtonsData) { button_data in
                    ProfileButtonEntrails(
                        title: button_data.title,
                        iconId: button_data.iconId,
                        action: button_data.action
                    )
                }
            }
        }
        .frame(height: 56 * CGFloat(ButtonsData.count))
        .padding(.horizontal)
    }
}

struct ProfileView: View {
    @EnvironmentObject var appSettings: AppSettings

    var FriendsButtons = [
        ProfileButton(title: "Send invite", iconId: "person.2"),
    ]
    var GeneralButtons = [
        ProfileButton(title: "Edit profile pricture", iconId: "person"),
        ProfileButton(title: "Edit name", iconId: "text.alignleft"),
        ProfileButton(title: "Cahange password", iconId: "key.viewfinder"),
    ]
    var SupportButtons = [
        ProfileButton(title: "Report a problem", iconId: "exclamationmark.bubble"),
        ProfileButton(title: "About app", iconId: "questionmark.square.dashed"),
    ]
    var AccountButtons = [
        ProfileButton(title: "Delete account", iconId: "xmark.circle"),
        ProfileButton(title: "Sign out", iconId: "stop", action: {
            logout("user tap")
        }),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    VStack {
                        Spacer().frame(height: 130)
                        ProfileBio()
                        ProfileGroupTitle(groupTitle: "Friends")
                        ProfileButtonsGroup(ButtonsData: FriendsButtons)
                        ProfileGroupTitle(groupTitle: "General settings")
                        ProfileButtonsGroup(ButtonsData: GeneralButtons)
                        ProfileGroupTitle(groupTitle: "Support")
                        ProfileButtonsGroup(ButtonsData: SupportButtons)
                        ProfileGroupTitle(groupTitle: "Account")
                        ProfileButtonsGroup(ButtonsData: AccountButtons)

                        Button("DEBUG MENU") {
                            appSettings.debugShow.toggle()
                        }

                        Spacer().frame(height: 20)
                        Text("Designed by Bubble Chat")
                            .font(.caption)
                            .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                            .foregroundStyle(.lightGrayText)
                        Spacer().frame(height: 120)
                    }
                }
            }

            HeaderTemplate(leftElement: Spacer(), centerElement: CenterProfileHeaderElement(), rightElement: RightProfileHeaderElement())
        }
    }
}
