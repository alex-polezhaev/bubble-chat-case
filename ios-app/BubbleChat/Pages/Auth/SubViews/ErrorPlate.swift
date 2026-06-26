//
//  ErrorPlate.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 03.10.2024.
//

import SwiftUI

struct ErrorPlate: View {
    @StateObject var viewModel: AuthViewModel

    var body: some View {
        VStack {
            if !viewModel.errorMsg.isEmpty {
                HStack {
                    Image(systemName: "info.circle")

                    Text(viewModel.errorMsg)
                        .font(.system(size: 16, weight: .medium, design: .rounded))

                }.foregroundColor(.red)
                    .frame(width: WIDTH * 0.85, height: 20, alignment: .leading)

            } else {
                Spacer()
            }
        }.frame(height: 12)
    }
}
