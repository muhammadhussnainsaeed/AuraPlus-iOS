import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = RegisterViewModel()
    @State private var isChecking = false
    @State private var isAvailable: Bool?
    @State private var errorMessage = ""
    @State private var moveToNext = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                // App Logo
                Image("Auralogo")
                    .resizable()
                    .frame(width: 250, height: 77)
                    .padding(.top, 30)
                    .padding(.bottom, 75)

                // Form Fields
                VStack(spacing: 24) {
                    InputView(text: $viewModel.username, title: "Username", placeholder: "Choose your username")
                        .autocorrectionDisabled()
                        .autocapitalization(.none)

                    InputView(text: $viewModel.name, title: "Name", placeholder: "Enter your name")
                        .autocorrectionDisabled()
                        .autocapitalization(.none)

                    InputView(text: $viewModel.password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureTextEntry: true)
                        .autocorrectionDisabled()

                    InputView(text: $viewModel.confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureTextEntry: true)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 30)

                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 10)
                }

                // Next Button
                Button {
                    errorMessage = ""

                    guard viewModel.isPasswordValid else {
                        errorMessage = "Password must be at least 8 characters, with uppercase, lowercase, and a number."
                        return
                    }

                    guard viewModel.doPasswordsMatch else {
                        errorMessage = "Passwords do not match."
                        return
                    }

                    isChecking = true
                    AuthService.shared.checkUsernameAvailable(username: viewModel.username) { available in
                        DispatchQueue.main.async {
                            self.isAvailable = available
                            self.isChecking = false

                            if available {
                                moveToNext = true
                            } else {
                                errorMessage = "Username is already taken."
                            }
                        }
                    }
                } label: {
                    if isChecking {
                        ProgressView()
                            .padding(.top, 60)
                    } else {
                        Text("Next")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .padding(.top, 60)
                    }
                }

                // Navigation to next screen
                NavigationLink(
                    destination: SecurityQuestionsView(viewModel: viewModel),
                    isActive: $moveToNext
                ) {
                    EmptyView()
                }

                Spacer()

                // Already have account
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack {
                        Text("Already have an account?")
                        Text("Sign In")
                            .fontWeight(.bold)
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
    SignupView()
}
