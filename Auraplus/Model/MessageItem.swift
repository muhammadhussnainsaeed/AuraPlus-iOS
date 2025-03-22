//
//  MessageItem.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import Foundation

struct MessageItem: Identifiable {
    let Id : UUID = UUID()
    let text: String
    let direction: MessageDirection
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return[MessageDirection.sent, received].randomElement() ?? .sent
    }
}
