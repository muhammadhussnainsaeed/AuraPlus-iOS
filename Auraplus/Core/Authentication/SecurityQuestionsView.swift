import SwiftUI

struct SecurityQuestionsView: View {
    
    @ObservedObject var viewModel: RegisterViewModel

    @State var ques1: String = ""
    @State var ques2: String = ""
    @State var ques3: String = ""
    @State var ques4: String = ""
    @State var ques5: String = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var registrationSuccess = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Account Recovery Questions")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top, 70)

                Text("These questions help verify your identity in case you need to recover your account.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fontWeight(.light)
                    .padding(.horizontal)
                    .padding(.bottom, 40)

                ScrollView {
                    VStack(spacing: 24) {
                        InputView(text: $ques1, title: "1. What is your mother's maiden name?", placeholder: "Smith")
                        InputView(text: $ques2, title: "2. What is the name of your first pet?", placeholder: "Buddy")
                        InputView(text: $ques3, title: "3. What was your first car?", placeholder: "Corolla")
                        InputView(text: $ques4, title: "4. What elementary school did you attend?", placeholder: "Public School")
                        InputView(text: $ques5, title: "5. What is the name of the town where you were born?", placeholder: "Islamabad")
                    }
                    .padding(.horizontal, 30)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 10)
                }

                Button {
                    errorMessage = ""
                    
                    guard !ques1.isEmpty, !ques2.isEmpty, !ques3.isEmpty, !ques4.isEmpty, !ques5.isEmpty else {
                        errorMessage = "Please answer all questions."
                        return
                    }

                    // Assign answers to viewModel
                    viewModel.question1 = ques1
                    viewModel.question2 = ques2
                    viewModel.question3 = ques3
                    viewModel.question4 = ques4
                    viewModel.question5 = ques5

                    isLoading = true

                    let request = RegisterRequest(
                            username: viewModel.username,
                            name: viewModel.name,
                            password: viewModel.password,
                            question1_answer: ques1,
                            question2_answer: ques2,
                            question3_answer: ques3,
                            question4_answer: ques4,
                            question5_answer: ques5
                        )
                    
                    AuthService.shared.registerUser(request) { success, error in
                            DispatchQueue.main.async {
                                isLoading = false
                                if success {
                                    registrationSuccess = true
                                } else {
                                    errorMessage = error
                                }
                            }
                        }

                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                }
                .padding(.top, 40)

                Spacer()

                NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true),
                               isActive: $registrationSuccess) {
                    EmptyView()
                }
            }
        }
    }
}
