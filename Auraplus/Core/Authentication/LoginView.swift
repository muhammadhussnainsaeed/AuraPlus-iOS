import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: SessionManager
    @State var username: String = ""
    @State var password: String = ""
    @State private var errorMessage = ""
    @State private var isChecking = false

    // Navigation flags
    @State private var goToForgetPassword = false
    @State private var goToSignup = false

    var body: some View {
        NavigationStack {
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

                Button {
                    goToForgetPassword = true
                } label: {
                    Text("Forget Password?")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                        .padding(.top, 25)
                }

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

                Button {
                    goToSignup = true
                } label: {
                    HStack {
                        Text("Don't have an account?")
                        Text("Signup").fontWeight(.bold)
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                    .padding(.top, 25)
                    .padding(.bottom, 15)
                }

                // Hidden navigation triggers
                NavigationLink(destination: ForgetPasswordView(), isActive: $goToForgetPassword) { EmptyView() }
                NavigationLink(destination: SignupView().navigationBarBackButtonHidden(true), isActive: $goToSignup) { EmptyView() }
            }

            .onReceive(session.$isLoggedIn) { loggedIn in
                if loggedIn {
                    isChecking = false
                    errorMessage = ""
                } else if isChecking {
                    isChecking = false
                    errorMessage = "User not found or incorrect credentials."
                }
            }

            .fullScreenCover(isPresented: Binding(
                get: { session.isLoggedIn },
                set: { newValue in if !newValue { session.logout() } })
            ) {
                HomeView()
                    .environmentObject(session)
                    .padding()
            }
        }
    }
}

#Preview("Login Screen") {
    NavigationStack {
        LoginView()
            .environmentObject(SessionManager())
    }
}
