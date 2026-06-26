//
//  CenterHomeHeaderElement.swift
//  BubbleChat
//
//  Created by polezhaev_aleksandr on 13.10.2024.
//

import SwiftUI

struct CenterHomeHeaderElement: View {
    var body: some View {
        VStack {
            Text("Bubbles")
                .fontDesign(.rounded)
                .fontWeight(.semibold)
            GrpcState()
        }
    }
}
