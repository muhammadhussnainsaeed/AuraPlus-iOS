//
//  InputView.swift
//  Auraplus
//
//  Created by Hussnain on 7/3/25.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureTextEntry: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(.darkGray))
                .fontWeight(.bold)
                .font(.footnote)
                .fontDesign(.default)
                
        
            if isSecureTextEntry{
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    
            }
            else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""),
              title: "Username",
              placeholder: " user123")
}
