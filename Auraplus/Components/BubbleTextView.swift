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
        VStack(alignment: item.horizantalAlignment, spacing: 3){
            Text("Hello! how are you?")
                .padding(9)
                .foregroundStyle(item.foregroundColor)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            timeStampTextView()
        }
        .frame(maxWidth: .infinity,alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 100)
        .padding(.trailing, item.direction == .received ? 100 :5)
    }
    
    private func timeStampTextView() -> some View {
        Text("12:34")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading, item.direction == .received ? 5 : 100)
            .padding(.trailing, item.direction == .received ? 100 :5)
    }
    
}

#Preview {
    BubbleTextView(item: .sentplaceholder)
    BubbleTextView(item: .receivedplaceholder)

}
