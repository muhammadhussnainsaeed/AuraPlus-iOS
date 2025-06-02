//
//  ForgetPasswordQuestionsView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//
import SwiftUI

struct ForgetPasswordQuestionsView: View {
    @State var username: String = ""
    @State var ques1: String = ""
    @State var ques2: String = ""
    @State var ques3: String = ""
    @State var ques4: String = ""
    @State var ques5: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToReset = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Account Recovery Questions")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top, 70)
                
                Text("Answer these questions as you entered them when you created your account.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom, 50)
                    .padding(.top, 1)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 24) {
                        InputView(text: $ques1, title: "1. What is your mother's maiden name?", placeholder: "Smith")
                        InputView(text: $ques2, title: "2. What is the name of your first pet?", placeholder: "Buddy")
                        InputView(text: $ques3, title: "3. What was your first car?", placeholder: "Corolla")
                        InputView(text: $ques4, title: "4. What elementary school did you attend?", placeholder: "Public School")
                        InputView(text: $ques5, title: "5. What is the name of the town where you were born?", placeholder: "Islamabad")
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)
                
                Button {
                    AuthService.shared.submitSecurityAnswers(
                        username: username,
                        q1: ques1,
                        q2: ques2,
                        q3: ques3,
                        q4: ques4,
                        q5: ques5,
                        onSuccess: {
                            navigateToReset = true
                        },
                        onFailure: { message in
                            alertMessage = message
                            showAlert = true
                        }
                    )
                } label: {
                    Text("Forget Password")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                        .padding(.bottom, 15)
                }
                .padding(.top, 60)
                
                NavigationLink(destination:NewPasswordView(username: username) .navigationBarBackButtonHidden(true),
                               isActive: $navigateToReset) {
                    EmptyView()
                }

                Spacer()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}


#Preview {
    ForgetPasswordQuestionsView()
}
