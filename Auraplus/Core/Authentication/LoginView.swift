//
//  LoginView.swift
//  Auraplus
//
//  Created by Hussnain on 7/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State var username: String = ""
    @State var password: String = ""
    @State private var errorMessage = ""
    @State private var isChecking = false
    @State private var isChecked = false
    
    var body: some View {
        VStack {
            Image("Auralogo")
                .resizable()
                .frame(width: 250, height: 77)
                .padding(.top, 30)
                .padding(.bottom, 75)
            
            VStack(spacing: 24) {
                InputView(text: $username, title: "Username", placeholder: "Enter your username")
                InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureTextEntry: true)
            }
            .padding(.horizontal, 30)
            .padding(.top, 12)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 10)
            }
            
            Button {
                errorMessage = ""
                isChecking = true
                session.login(username: username, password: password)
            } label: {
                if isChecking {
                    ProgressView()
                        .padding(.top, 60)
                } else {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.top, 60)
                }
            }
            .padding(.top, 60)
            .disabled(isChecking)
            
            Spacer()
            
            NavigationLink {
                SignupView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                HStack {
                    Text("Don't have an account?")
                    Text("Signup").fontWeight(.bold)
                }
                .foregroundColor(.blue)
                .font(.system(size: 14))
                .padding(.top, 25)
            }
        }
        .onReceive(session.$isLoggedIn) { loggedIn in
            if loggedIn {
                // Login succeeded
                isChecking = false
                errorMessage = ""
            } else if isChecking {
                // Login failed
                isChecking = false
                errorMessage = "User not found or incorrect credentials."
            }
        }
        // fullScreenCover directly on the VStack (root view)
        .fullScreenCover(isPresented: Binding(
            get: { session.isLoggedIn },
            set: { newValue in
                if !newValue {
                    session.logout()
                }
            })
        ) {
            HomeView()
                .environmentObject(session)
                .padding()
        }
    }
}

#Preview("Login Screen") {
    NavigationStack {
        LoginView()
            .environmentObject(SessionManager())
    }
}

