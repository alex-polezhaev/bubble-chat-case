//
//  AddContactGroup.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 06.10.2024.
//

import SwiftUI

struct AddContactGroup: View {
    var contacts: [Contact] // Plain prop, when the list does not need to be modified

    @State private var showCount = 100

    var body: some View {
        VStack {
            GroupHeader(title: "Add your contacts", counter: contacts.count)

            ForEach(Array(contacts.prefix(showCount)), id: \.self) { contact in
                ContactBadge(buttonTitle: "Invite", contact: contact) {
                    // TODO:
                }
            }

            if showCount < contacts.count {
                Button(action: {
                    withAnimation {
                        showCount += 200
                    }
                }) {
                    ShowMore() // "Show more" button
                }
            }
        }
    }
}
