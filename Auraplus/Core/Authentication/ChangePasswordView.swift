//
//  ChangePasswordView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var session: SessionManager
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // ✅ Password validation logic
    private func isPasswordValid(_ password: String) -> Bool {
        let regex = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Change your Password")
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
                        InputView(text: $oldPassword,
                                  title: "Password",
                                  placeholder: "Enter your old password",
                                  isSecureTextEntry: true)
                            .autocorrectionDisabled()
                            .padding(.top, 12)
                        
                        InputView(text: $newPassword,
                                  title: "New Password",
                                  placeholder: "Enter new password",
                                  isSecureTextEntry: true)
                            .autocorrectionDisabled()
                            .padding(.top, 12)
                        
                        InputView(text: $confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Confirm new password",
                                  isSecureTextEntry: true)
                            .autocorrectionDisabled()
                            .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)
                
                Button {
                    // ✅ Form validation when button is tapped
                    guard !oldPassword.isEmpty,
                          !newPassword.isEmpty,
                          !confirmPassword.isEmpty else {
                        alertMessage = "All fields are required."
                        showAlert = true
                        return
                    }
                    
                    guard newPassword == confirmPassword else {
                        alertMessage = "New password and confirmation do not match."
                        showAlert = true
                        return
                    }
                    
                    guard isPasswordValid(newPassword) else {
                        alertMessage = "Password must be at least 8 characters, including uppercase, lowercase, and a number."
                        showAlert = true
                        return
                    }
                    
                    guard let username = session.currentUser?.username else {
                        alertMessage = "Unable to fetch current user."
                        showAlert = true
                        return
                    }

                    AuthService.shared.updatePassword(username: username, oldPassword: oldPassword, newPassword: newPassword) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let message):
                                alertMessage = message
                                showAlert = true
                                oldPassword = ""
                                newPassword = ""
                                confirmPassword = ""
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                } label: {
                    Text("Change Password")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.bottom, 15)
                }
                .padding(.top, 60)
                .alert("Password Update", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(SessionManager.shared)
}
