//
//  ChangePasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @State var oldPassword: String = ""
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                Text("Change your Password")
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
                        InputView(text: $oldPassword,
                                  title: "Password",
                                  placeholder: "Enter your old password",
                                  isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                        
                        InputView(text: $newPassword,
                                  title: "New Password",
                                  placeholder: "Enter new password",
                                  isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                        
                        InputView(text: $confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Confirm new password",
                                  isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                    }
                }
                .padding(.horizontal,30)
                .padding(.top,12)
                
                Button {
                    
                } label: {
                    Text("Confirm")
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
    ChangePasswordView()
}
