//
//  ChatItemView.swift
//  Auraplus
//
//  Created by Hussnain on 9/3/25.
//

import SwiftUI

struct ChatItemView: View {
    @State var name: String = ""
    @State var lastmessage: String = ""
    @State var time = ""
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            Image(systemName: "person.crop.circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 50))
            VStack(alignment: .leading, spacing: 3){
                HStack{
                    Text(name)
                        .lineLimit(1)
                        .bold()
                    
                    Spacer()
                    
                    Text(time)
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                }
                Text(lastmessage)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .foregroundColor(.gray)

             }
        }
    }
}

#Preview {
    ChatItemView(name: "Ali", lastmessage: "hello ", time: "12:20 PM")
}
