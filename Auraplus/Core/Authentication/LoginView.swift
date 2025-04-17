//
//  LoginView.swift
//  Auraplus
//
//  Created by Hussnain on 7/3/25.
//

import SwiftUI

struct LoginView: View {
    @State var user: String = ""
    @State var password: String = ""
    var body: some View {
        NavigationStack{
            VStack{
                //image
                Image("Auralogo")
                    .resizable()
                    .frame(width: 250, height: 77)
                    .padding()
                    .padding(.top,30)
                    .padding(.bottom,75)
                
                //form fields
                VStack(spacing: 24){
                    InputView(text: $user, title: "Username", placeholder: "Enter your username")
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                }
                .padding(.horizontal,30)
                .padding(.top,12)
                //forgot
                Text("Forgot your password?")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
                    .padding(.top,25)
                //signin btn
                Button {
                    
                } label: {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.top,60)
                
                Spacer()
                
                //signup btn
                
                NavigationLink{
                    SignupView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    HStack{
                        Text("Don't have an account?")
                        Text("Signup")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                    .padding(.top,25)
                }

                
                
            }
        }
    }
}
#Preview {
    LoginView()
}
