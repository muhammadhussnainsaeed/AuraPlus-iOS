import SwiftUI

struct GroupItemView: View {
    let group: GroupPreview
    private var decryptedMessage: String {
        if let encrypted = group.lastMessage,
           let decrypted = AESHelper.shared.decrypt(base64CipherText: encrypted),
           !decrypted.isEmpty {
            return decrypted
        } else {
            return group.lastMessage ?? "No message yet"
        }
    }


    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.2.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(group.groupName)
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Text(formattedTime)
                        .foregroundColor(.gray)
                        .font(.caption)
                }

                Text(decryptedMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Time Formatting
    private var formattedTime: String {
        guard let rawTime = group.lastMessageTime else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: rawTime) else {
            return "" // fallback if parsing fails
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
}
