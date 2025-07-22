//
//  GroupMessage.swift
//  Auraplus
//
//  Created by Hussnain on 21/6/25.
//

import Foundation

// MARK: - Group Message Model (Backend)
struct GroupMessage: Codable, Identifiable {
    let id: Int?
    let group_id: Int
    let sender_id: Int
    let username: String
    let content: String?
    let media_url: String?
    let message_type: String
    let time_stamp: String  // ISO formatted date string from backend

    enum CodingKeys: String, CodingKey {
            case id
            case group_id = "chat_id"
            case sender_id
            case username
            case content
            case media_url
            case message_type
            case time_stamp
        }
}

// MARK: - Group Message Create (Sending)
struct GroupMessageCreate: Codable {
    let group_id: Int
    let sender_id: Int
    let content: String?
    let media_url: String?
    let message_type: String
}
