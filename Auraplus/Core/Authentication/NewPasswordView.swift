//
//  NewPasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct NewPasswordView: View {
    @State var username: String = ""
    @State var password1: String = ""
    @State var password2: String = ""
    
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    @State private var navigateToLogin: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Enter new Password")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top, 70)
                
                Text("Make sure your password is strong and unique.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom, 50)
                    .padding(.top, 1)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 24) {
                        InputView(
                            text: $password1,
                            title: "Password",
                            placeholder: "Enter your password",
                            isSecureTextEntry: true
                        )
                        .autocorrectionDisabled()
                        .padding(.top, 12)
                        
                        InputView(
                            text: $password2,
                            title: "Confirm Password",
                            placeholder: "Confirm your password",
                            isSecureTextEntry: true
                        )
                        .autocorrectionDisabled()
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)
                
                Button {
                    // Form validation
                    guard !username.isEmpty else {
                        alertMessage = "Username is missing."
                        showingAlert = true
                        return
                    }
                    
                    guard !password1.isEmpty, !password2.isEmpty else {
                        alertMessage = "Please fill in both password fields."
                        showingAlert = true
                        return
                    }
                    
                    guard password1 == password2 else {
                        alertMessage = "Passwords do not match."
                        showingAlert = true
                        return
                    }
                    
                    // API call
                    AuthService.shared.updateForgottenPassword(username: username, newPassword: password1) {
                        alertMessage = "Password updated successfully."
                        showingAlert = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToLogin = true
                        }
                    } onFailure: { error in
                        alertMessage = error
                        showingAlert = true
                    }
                } label: {
                    Text("Confirm")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.bottom, 15)
                }
                .padding(.top, 60)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Notice"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Spacer()
                
                // NavigationLink hidden but triggered programmatically
                NavigationLink(
                    destination: LoginView()
                        .environmentObject(SessionManager.shared)
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToLogin
                ) {
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    NewPasswordView()
}
