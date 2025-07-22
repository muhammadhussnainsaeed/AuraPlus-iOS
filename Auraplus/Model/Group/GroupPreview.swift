//
//  GroupPreview.swift
//  Auraplus
//
//  Created by Hussnain on 20/6/25.
//

import Foundation

struct GroupPreview: Identifiable, Codable {
    let groupId: Int
    let groupName: String
    let lastMessage: String?
    let lastMessageTime: String?

    var id: Int { groupId } // For Identifiable conformance

    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case groupName = "group_name"
        case lastMessage = "last_message"
        case lastMessageTime = "last_time"
    }
}
