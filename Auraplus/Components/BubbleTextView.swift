//
//  BubbleTextView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct BubbleTextView: View {
    
    let item: MessageItem
    var body: some View {
        Text("Hello! how are you?")
            .padding(9)
            .foregroundStyle(item.foregroundColor)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    BubbleTextView(item: .sentplaceholder)
    BubbleTextView(item: .receivedplaceholder)
}
