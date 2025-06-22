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
        VStack(alignment: item.horizantalAlignment, spacing: 3) {
            Text(item.text)
                .padding(9)
                .foregroundColor(item.foregroundColor)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(item.timestamp)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, item.direction == .received ? 5 : 100)
                .padding(.trailing, item.direction == .received ? 100 : 5)
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 100)
        .padding(.trailing, item.direction == .received ? 100 : 5)
    }
}

#Preview {
    VStack(spacing: 20) {
        BubbleTextView(item: MessageItem(
            text: "Hello! How are you?",
            type: .text,
            direction: .sent,
            timestamp: "10:45 AM"
        ))

        BubbleTextView(item: MessageItem(
            text: "I'm good, thank you!",
            type: .text,
            direction: .received,
            timestamp: "10:46 AM"
        ))
    }
    .padding()
}

