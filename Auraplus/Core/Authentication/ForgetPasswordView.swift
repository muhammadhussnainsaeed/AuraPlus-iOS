//
//  ForgetPasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct ForgetPasswordView: View {
    @State var username: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUserValid = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Forget your Password")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top, 70)

                Text("There are few steps to reset your password.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom, 50)
                    .padding(.top, 1)
                    .padding(.horizontal)

                ScrollView {
                    InputView(text: $username, title: "Username", placeholder: "Enter your username")
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)

                NavigationLink(destination: ForgetPasswordQuestionsView(username: username) .navigationBarBackButtonHidden(true), isActive: $isUserValid) {
                    EmptyView()
                }

                Button {
                    if username.isEmpty {
                        alertMessage = "Please enter your username."
                        showAlert = true
                        return
                    }

                    AuthService.shared.checkUsernameAvailable(username: username) { available in
                        DispatchQueue.main.async {
                            if !available {
                                isUserValid = true
                            } else {
                                alertMessage = "User not found."
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    Text("Next")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.bottom, 15)
                }
                .padding(.top, 60)
                .alert("Username Check", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(alertMessage)
                }

                Spacer()
            }
        }
    }
}


#Preview {
    ForgetPasswordView()
}
