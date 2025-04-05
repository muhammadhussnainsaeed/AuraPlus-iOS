//
//  bubbleImageView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI

struct bubbleImageView: View {
    let item: MessageItem
    var body: some View {
        HStack{
            if item.direction == .sent {
                Spacer()
            }
            
            messageTextView()
                .overlay{
                    playButton()
                        .opacity(item.type == .video ? 1 : 0)
                }
            
            if item.direction == .received {
                Spacer()
            }
            
        }
    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.primary)
            .background(.thinMaterial)
            .clipShape(Circle())
            .padding(.bottom)
    }
    
    private func messageTextView() -> some View {
        VStack{
            VStack(alignment: .leading,spacing: 3){
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height:180)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    ).background{
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.secondary)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary)
                    )
                    .padding(7)
            }
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            timeStampTextView()
        }
        .padding(5)

    }
    
    private func timeStampTextView() -> some View {
        Text("12:34")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading, item.direction == .received ? 5 : 200)
            .padding(.trailing, item.direction == .received ? 200 : 5)
    }
    
}

#Preview {
    bubbleImageView(item: .sentplaceholder)
    bubbleImageView(item: .receivedplaceholder)
}
