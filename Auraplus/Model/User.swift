//
//  User.swift
//  Auraplus
//
//  Created by Hussnain on 9/3/25.
//

import Foundation
import SwiftUICore
import UIKit

struct User: Identifiable , Codable {
    var id: String
    var username: String
    var name: String
    var isonline: Bool
    var profileImageData: Data? // From backend (bytea)

        // Computed property to generate a SwiftUI image
        var profileImage: Image {
            if let data = profileImageData, let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "person.crop.circle") // fallback
            }
        }
}

//extension User {
//    static var MockUser = User(id: UUID().uuidString, username: "mock", name: "Mock User")
//}
