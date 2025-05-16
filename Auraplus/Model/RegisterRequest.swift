//
//  RegisterRequest.swift
//  Auraplus
//
//  Created by Hussnain on 2/5/25.
//

import Foundation

struct RegisterRequest: Codable {
    let username: String
    let name: String
    let password: String
    let question1_answer: String
    let question2_answer: String
    let question3_answer: String
    let question4_answer: String
    let question5_answer: String
}

