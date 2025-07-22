import Foundation
import SwiftUI

struct GroupMessageItem: Identifiable {
    let id = UUID().uuidString
    let messageid: Int
    let text: String
    let type: MessageType
    let media_url: String?
    let direction: MessageDirection
    let timestamp: String
    let username: String

    // MARK: - Initializer from backend GroupMessage model
    init(from message: GroupMessage, currentUsername: String) {
        self.text = message.content ?? ""
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
        self.direction = message.username == currentUsername ? .sent : .received
        self.timestamp = Self.formatDateString(message.time_stamp)
        self.media_url = message.media_url
        self.messageid = message.id ?? 0
    }

    // MARK: - Timestamp Formatter
    static func formatDateString(_ rawTime: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: rawTime) else {
            return rawTime
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

    // MARK: - Helpers
    static func parseMessageType(_ type: String) -> MessageType {
        switch type.lowercased() {
        case "text": return .text
        case "photo": return .photo
        case "video": return .video
        case "audio": return .audio
        default: return .text
        }
    }

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

    // MARK: - Previews
    static let sentPlaceholder = GroupMessageItem(
        from: GroupMessage(
            id: 1,
            group_id: 1,
            sender_id: 1,
            username: "me",
            content: "Hello group!",
            media_url: nil,
            message_type: "text",
            time_stamp: "2025-06-23T13:00:00.00000"
        ),
        currentUsername: "me"
    )
}
