//
//  NewPasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct NewPasswordView: View {
    @State var password1: String = ""
    @State var password2: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                Text("Enter new Password")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top,70)
                Text("Make sure your password is strong and unique.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom,50)
                    .padding(.top,1)
                    .padding(.horizontal)
                
                ScrollView{
                    VStack(spacing: 24){
                        InputView(text: $password1,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureTextEntry: true)
                            .autocorrectionDisabled()
                            .padding(.top,12)
                        InputView(text: $password2,
                                  title: "Confirm Password",
                                  placeholder: "Confirm your password",
                                  isSecureTextEntry: true)
                            .autocorrectionDisabled()
                            .padding(.top,12)
                    }
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
}

#Preview {
    NewPasswordView()
}
