//
//  User.swift
//  Auraplus
//
//  Created by Hussnain on 9/3/25.
//

import Foundation

struct User: Identifiable , Codable {
    var id: String
    var username: String
    var name: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name){
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension User {
    static var MockUser = User(id: UUID().uuidString, username: "mock", name: "Mock User")
}
