//
//  SecurityQuestionsView.swift
//  Auraplus
//
//  Created by Hussnain on 8/3/25.
//

import SwiftUI

struct SecurityQuestionsView: View {
    @State var ques1: String = ""
    @State var ques2: String = ""
    @State var ques3: String = ""
    @State var ques4: String = ""
    @State var ques5: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                Text("Account Recovery Questions")
                    .font(.system(size: 19))
                    .fontWeight(.bold)
                    .padding(.top,70)
                Text("These questions help verify your identity in case you need to recover your account.")
                    .multilineTextAlignment(.center)
                    .font(.system(.caption))
                    .fontWeight(.light)
                    .padding(.bottom,50)
                    .padding(.top,1)
                    .padding(.horizontal)
                //form fields
                ScrollView{
                    VStack(spacing: 24){
                        InputView(text: $ques1, title: "1. What is your mother's maiden name?", placeholder: "Smith")
                            .autocorrectionDisabled()
                        InputView(text: $ques2, title: "2. What is the name of your first name?", placeholder: "Buddy")
                            .autocorrectionDisabled()
                        InputView(text: $ques3, title: "3. What was your first car?", placeholder: "Corolla")
                            .autocorrectionDisabled()
                        InputView(text: $ques4, title: "4. What elementary school did you attend?", placeholder: "Public School")
                            .autocorrectionDisabled()
                        InputView(text: $ques5, title: "5. What is the name of the town where you were born?", placeholder: "Islamabad")
                            .autocorrectionDisabled()
                    }
                }
                
                .padding(.horizontal,30)
                .padding(.top,12)
                
                //signin btn
                Button {
                    dismiss()
                } label: {
                    Text("SignUp")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.top,60)
                
                Spacer()
                
                //signup btn
                
//                NavigationLink{
//                    LoginView()
//                        .navigationBarBackButtonHidden(true)
//                }label: {
//                    HStack{
//                        Text("Already have an account?")
//                        Text("SignIn")
//                            .fontWeight(.bold)
//                    }
//                    .foregroundColor(.blue)
//                    .font(.system(size: 14))
//                    .padding(.top,25)
//                }
            }
        }
    }
}

#Preview {
    SecurityQuestionsView()
}
