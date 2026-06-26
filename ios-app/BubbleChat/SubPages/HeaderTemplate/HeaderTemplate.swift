//
//  HeaderTemplate.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct HeaderTemplate<Left: View, Center: View, Right: View>: View {
    let leftElement: Left
    let centerElement: Center
    let rightElement: Right

    var gradient = Gradient(stops:
        [
            .init(color: .background,
                  location: 0),
            .init(color: .background,
                  location: 0.7),
            .init(color: .clear,
                  location: 1),
        ])

    var columns = [
        GridItem(.flexible()), // Flexible-width column
        GridItem(.fixed(WIDTH * 0.6)), // Second column
        GridItem(.flexible()), // Third column
    ]

    var height: CGFloat = 130

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle().fill(gradient).frame(height: height)

            LazyVGrid(columns: columns) {
                leftElement
                    .frame(maxWidth: .infinity, alignment: .leading)

                centerElement
                    .frame(maxWidth: .infinity, alignment: .center)

                rightElement
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .padding(.top, 40)

        }.frame(maxHeight: .infinity, alignment: .top)
    }
}
