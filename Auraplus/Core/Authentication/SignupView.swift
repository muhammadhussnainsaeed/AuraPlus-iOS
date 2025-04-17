
//  Created by Hussnain on 7/3/25.
//

import SwiftUI

struct SignupView: View {
    @State var user: String = ""
    @State var password1: String = ""
    @State var password2: String = ""

    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack{
            VStack{
                //image
                Image("Auralogo")
                    .resizable()
                    .frame(width: 250, height: 77)
                    .padding()
                    .padding(.top,30)
                    .padding(.bottom,75)
                
                //form fields
                VStack(spacing: 24){
                    InputView(text: $user, title: "Username", placeholder: "Choose your username")
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    InputView(text: $user, title: "Name", placeholder: "Enter your name")
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                    InputView(text: $password1,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                    InputView(text: $password2,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureTextEntry: true)
                        .autocorrectionDisabled()
                        .padding(.top,12)
                }
                .padding(.horizontal,30)
                .padding(.top,12)
                
                //signin btn
                Button {
                    print("hello")
                } label: {
                    Text("Next")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.top,60)
                
                Spacer()
                
                //signup btn
                
                NavigationLink{
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    HStack{
                        Text("Already have an account?")
                        Text("SignIn")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                    .padding(.top,25)
                }

                
                
            }
        }
    }
}
#Preview {
    SignupView()
}
