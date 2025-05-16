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
    @State private var token: String? = nil
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack {
                Image("Auralogo")
                    .resizable()
                    .frame(width: 250, height: 77)
                    .padding(.top, 30)
                    .padding(.bottom, 75)

                VStack(spacing: 24) {
                    InputView(text: $user, title: "Username", placeholder: "Enter your username")
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureTextEntry: true)
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)

                Button {
                    AuthService.shared.login(username: user, password: password) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let token):
                                self.token = token
                                self.navigateToHome = true
                            case .failure(let error):
                                print("Login error: \(error.localizedDescription)")
                            }
                        }
                    }
                } label: {
                    Text("Sign In")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.top, 60)

                // Navigation trigger
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }

                Spacer()
                NavigationLink {
                    SignupView().navigationBarBackButtonHidden(true)
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
        }
    }
}

#Preview {
    LoginView()
}
