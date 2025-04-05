//
//  ForgetPasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct ForgetPasswordView: View {
    @State var username: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                Text("Forget your Password")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top,70)
                Text("There are few steps to reset your password.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom,50)
                    .padding(.top,1)
                    .padding(.horizontal)
            }
            ScrollView{
                InputView(text: $username, title: "Username", placeholder: "Enter your username")
                    .autocorrectionDisabled()
            }
            .padding(.horizontal,30)
            .padding(.top,12)
            
            Button {
                
            } label: {
                Text("Next")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
            }
            .padding(.top,60)
            
            Spacer()
        }
    }
}

#Preview {
    ForgetPasswordView()
}
