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
    
    @ViewBuilder
    private func messageTextView() -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if let urlString = item.media_url, let url = URL(string: urlString) {
                switch item.type {
                case .photo:
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Image(systemName: "xmark.octagon.fill")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 220, height: 180)
                    .clipped()

                case .video:
                    ZStack {
                        VideoThumbnailView(videoURL: url)
                            .frame(width: 220, height: 180)
                            .clipped()
                        playButton()
                    }

                default:
                    EmptyView()
                }
            }
        }
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary)
        )
        .padding(7)
    }

    
    private func timeStampTextView() -> some View {
        Text(item.timestamp)
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
