import Foundation
import SwiftUI

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let messageid: Int
    let text: String?
    let type: MessageType
    let media_url: String?
    let direction: MessageDirection
    let timestamp: String
    let username: String
    
    // MARK: - Initializer for converting backend model
    init(from message: Message, currentUsername: String) {
        self.text = message.content
        self.type = {
            switch message.message_type.lowercased() {
            case "text": return .text
            case "photo": return .photo
            case "video": return .video
            case "audio": return .audio
            default: return .text
            }
        }()
        self.username = message.username
        self.direction = currentUsername == message.username ? .sent : .received
        self.timestamp = Self.formatDateString(message.time_stamp)
        self.media_url = message.media_url
        self.messageid = message.id ?? 0
    }

    // MARK: - Manual initializer for previews/testing
    init(text: String, type: MessageType, direction: MessageDirection, timestamp: String = "Now") {
        self.text = text
        self.type = type
        self.direction = direction
        self.timestamp = timestamp
        self.username = "hi"
        self.media_url = nil
        self.messageid = 0
    }

    // MARK: - UI Helpers
    var alignment: Alignment {
        direction == .received ? .leading : .trailing
    }

    var horizantalAlignment: HorizontalAlignment {
        direction == .received ? .leading : .trailing
    }

    var foregroundColor: Color {
        direction == .sent ? .white : .primary
    }

    var backgroundColor: Color {
        direction == .sent ? .blue : .gray.opacity(0.2)
    }

    // MARK: - Timestamp formatter
    static func formatDateString(_ rawTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS" // Matches: "2025-06-21 14:07:37.17388"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: rawTime) else {
            return rawTime  // fallback to raw if parsing fails
        }

        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"
            return weekdayFormatter.string(from: date)
        } else {
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "yyyy-MM-dd"
            return fullFormatter.string(from: date)
        }
    }

    // MARK: - Static placeholders for previews
    static let sentplaceholder = MessageItem(text: "What's up?", type: .text, direction: .sent)
    static let receivedplaceholder = MessageItem(text: "Hey!!!", type: .text, direction: .received)
}

// MARK: - Enums

enum MessageType {
    case text, photo, video, audio
}

enum MessageDirection {
    case sent, received

    static var random: MessageDirection {
        return [.sent, .received].randomElement() ?? .sent
    }
}
