//
//  BubbleTextViewG.swift
//  Auraplus
//
//  Created by Hussnain on 23/6/25.
//

import SwiftUI

struct BubbleTextViewG: View {
    let item: GroupMessageItem
    var onDelete: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: item.horizantalAlignment, spacing: 3) {
            if item.direction == .received {
                // 🟢 Show sender name only for received messages
                Text(item.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.leading, 4)
            }

            Text(item.text)
                .padding(9)
                .foregroundColor(item.foregroundColor)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .onLongPressGesture {
                    onDelete?()
                }

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



