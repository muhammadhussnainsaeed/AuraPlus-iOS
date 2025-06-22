//
//  ChatHeaderView.swift
//  Auraplus
//
//  Created by Hussnain on 5/4/25.
//

import SwiftUI

enum TypingStatus {
    case typing
    case stoppedTyping

    var label: String {
        switch self {
        case .typing: return "Typing..."
        case .stoppedTyping: return ""
        }
    }
}

enum UserStatus {
    case online
    case offline

    var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .gray
        }
    }

    var label: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline"
        }
    }
}

struct ChatHeaderView: View {
    let name: String
    let username: String
    let profilePictureBase64: String?
    let status: UserStatus
    let typingStatus: TypingStatus

    var body: some View {
        HStack(spacing: 12) {
            profileImage
                .frame(width: 45, height: 45)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 17, weight: .bold))

                if typingStatus == .typing {
                    Text(typingStatus.label)
                        .font(.caption)
                        .foregroundColor(.gray)
                } else {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(status.color)
                            .frame(width: 8, height: 8)
                        Text(status.label)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }

    // MARK: - Profile Image Logic
    private var profileImage: some View {
        if let base64 = profilePictureBase64,
           let data = Data(base64Encoded: base64.replacingOccurrences(of: "data:image/png;base64,", with: "")),
           let uiImage = UIImage(data: data) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        } else {
            return AnyView(
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.gray) // ensures it appears gray even in dark mode
            )
        }
    }
}

#Preview {
    VStack {
        ChatHeaderView(
            name: "Umer",
            username: "umer",
            profilePictureBase64: nil,
            status: .online,
            typingStatus: .stoppedTyping
        )
        ChatHeaderView(
            name: "Ali",
            username: "ali123",
            profilePictureBase64: nil,
            status: .offline,
            typingStatus: .stoppedTyping
        )
    }
}

