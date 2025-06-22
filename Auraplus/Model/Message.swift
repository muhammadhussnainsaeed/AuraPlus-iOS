//
//  Message.swift
//  Auraplus
//
//  Created by Hussnain on 21/6/25.
//

import Foundation
import SwiftUI

// MARK: - Message Model (Backend)
struct Message: Codable, Identifiable {
    let id: Int?
    let chat_id: Int
    let sender_id: Int
    let username: String
    let content: String
    let media_url: String?
    let message_type: String
    let time_stamp: String  // Will now correctly map from "created_at"

    enum CodingKeys: String, CodingKey {
            case id, chat_id, sender_id, username, content, media_url, message_type
            case time_stamp = "time_stamp"  // Map correctly from your API
        }
}

// MARK: - MessageCreate (Sending)
struct MessageCreate: Codable {
    let chat_id: Int
    let sender_id: Int
    let content: String
    let media_url: String?
    let message_type: String
}
