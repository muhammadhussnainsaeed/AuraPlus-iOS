import SwiftUI

struct ChatItemView: View {
    let chat: ChatPreview
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            profileImage
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formattedTime)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Text(chat.lastMessage ?? "No message yet")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Profile Image
    
    private var profileImage: some View {
        Group {
            if let base64 = chat.profilePictureBase64,
               let data = Data(base64Encoded: base64.replacingOccurrences(of: "data:image/png;base64,", with: "")),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    // MARK: - Time Formatting
    
    private var formattedTime: String {
        guard let rawTime = chat.lastMessageTime else { return "" }

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
            weekdayFormatter.dateFormat = "EEEE" // e.g., "Monday"
            return weekdayFormatter.string(from: date)
        } else {
            let fullFormatter = DateFormatter()
            fullFormatter.dateFormat = "yyyy-MM-dd"
            return fullFormatter.string(from: date)
        }
    }
}


#Preview {
    ChatItemView(chat: ChatPreview(
        id: 101,
        withUsername: "ali123",
        name: "Ali Raza",
        withUsernameId: 4,
        profilePictureBase64: nil, // You can test with actual base64 string
        lastMessage: "Hey! Let's catch up later today.",
        lastMessageTime: "2025-06-20T14:36:11.220367"
    ))
}
