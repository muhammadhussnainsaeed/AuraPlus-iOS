//
//  MessageItem.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import Foundation

import SwiftUI

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let text: String
    let type: MessageType
    let direction: MessageDirection
    
    static let sentplaceholder = MessageItem(text: "What's up?", type: .text, direction: .sent)
    static let receivedplaceholder = MessageItem(text: "Hey!!!", type: .text, direction: .received)
    
    var alignment: Alignment {
        return direction == .received ? .leading : .trailing
    }
    
    var horizantalAlignment: HorizontalAlignment {
        return direction == .received ? .leading : .trailing
    }
    
    var foregroundColor: Color {
        return direction == .sent ? .white : .primary
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .blue : .gray.opacity(0.2)
    }
    
    static let stubMessage: [MessageItem] = [
        MessageItem(text: "Hi there", type: .text, direction: .sent),
        MessageItem(text: "Check out this photo", type: .photo, direction: .received),
        MessageItem(text: "Play this video", type: .video, direction: .sent),
        MessageItem(text: "", type: .audio, direction: .sent),
        MessageItem(text: "", type: .audio, direction: .received)

        ]
    
}

enum MessageType {
    case text, photo, video, audio

}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return[MessageDirection.sent, received].randomElement() ?? .sent
    }
}
