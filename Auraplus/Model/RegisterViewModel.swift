//
//  RegisterViewModel.swift
//  Auraplus
//
//  Created by Hussnain on 2/5/25.
//

import Foundation

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var question1 = ""
    @Published var question2 = ""
    @Published var question3 = ""
    @Published var question4 = ""
    @Published var question5 = ""

    var isPasswordValid: Bool {
            // At least 8 characters, one upper, one lower, one digit
            let regex = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$"#
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
        }

    var doPasswordsMatch: Bool {
            return password == confirmPassword
        }
    
    func toRegisterRequest() -> RegisterRequest {
        RegisterRequest(
            username: username,
            name: name,
            password: password,
            question1_answer: question1,
            question2_answer: question2,
            question3_answer: question3,
            question4_answer: question4,
            question5_answer: question5
        )
    }
}
