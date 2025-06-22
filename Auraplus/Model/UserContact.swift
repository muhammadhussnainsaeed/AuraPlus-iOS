//
//  UserContact.swift
//  Auraplus
//
//  Created by Hussnain on 15/6/25.
//

import Foundation
import SwiftUI
import UIKit

struct UserContact: Identifiable {
    let id = UUID()
    let username: String
    let name: String
    let profileImageData: Data?

    var profileImage: Image {
        if let data = profileImageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "person.crop.circle.fill")
                .renderingMode(.template) // Fallback icon
        }
    }

    init(username: String, name: String, profileImageBase64: String?) {
        self.username = username
        self.name = name
        if let base64 = profileImageBase64,
           let data = Data(base64Encoded: base64) {
            self.profileImageData = data
        } else {
            self.profileImageData = nil
        }
    }
}
