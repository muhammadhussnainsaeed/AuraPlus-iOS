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
    let direction: MessageDirection
    
    static let sentplaceholder = MessageItem(text: "What's up?", direction: .sent)
    static let receivedplaceholder = MessageItem(text: "Hey!!!", direction: .received)
    
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
    
}

enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return[MessageDirection.sent, received].randomElement() ?? .sent
    }
}
