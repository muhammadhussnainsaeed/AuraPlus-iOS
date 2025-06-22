//
//  ChatPreview.swift
//  Auraplus
//
//  Created by Hussnain on 20/6/25.
//

import Foundation

struct ChatPreview: Identifiable, Codable {
    let id: Int                // chat_id from API
    let withUsername: String
    let name: String
    let withUsernameId: Int
    let profilePictureBase64: String?
    let lastMessage: String?
    let lastMessageTime: String?

    enum CodingKeys: String, CodingKey {
        case id = "chat_id"
        case withUsername = "with_username"
        case name
        case withUsernameId = "with_user_id"
        case profilePictureBase64 = "profile_picture_base64"
        case lastMessage = "last_message"
        case lastMessageTime = "last_message_time"
    }
}
