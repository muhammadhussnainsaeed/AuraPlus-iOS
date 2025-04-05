//
//  BubbleAudioView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var silderRange: ClosedRange<Double> = 0...20
    var body: some View {
        VStack(alignment: item.horizantalAlignment, spacing: 3){
            HStack
            {
                PlayButton()
                Slider(value: $sliderValue, in: silderRange)
                    .tint(item.foregroundColor)
                    .onAppear{
                        let thumbImage = UIImage(systemName: "circle.fill")!
                        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
                    }
                Text("04:00")
                    .font(.system(size: 12))
                    .foregroundStyle(item.foregroundColor)
                
            }
            .padding(8)
            .background(item.backgroundColor)
            .frame(width: 250,height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            timeStampTextView()
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 10)
        .padding(.trailing, item.direction == .received ? 10 :5)
    }
    
    private func PlayButton() -> some View {
        Button{
            
        } label: {
            Image(systemName: "play.fill")
                .padding(10)
                .foregroundStyle(item.foregroundColor)
        }
    }
    
    private func timeStampTextView() -> some View {
        Text("12:34")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.leading, item.direction == .received ? 5 : 15)
            .padding(.trailing, item.direction == .received ? 15 :5)
    }
    
}

#Preview {
    ScrollView{
        BubbleAudioView(item: .receivedplaceholder)
        BubbleAudioView(item: .sentplaceholder)
    }
    .padding()
    .frame(maxWidth: .infinity)
    .onAppear{
        let thumbImage = UIImage(systemName: "circle.fill")!
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
