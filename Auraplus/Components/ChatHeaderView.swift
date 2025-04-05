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
    let username: String
    let status: UserStatus
    let typingStatus: TypingStatus

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 2) {
                Text(username)
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
}


#Preview {
    ChatHeaderView(username: "Umer", status: .online, typingStatus: .typing)
    ChatHeaderView(username: "umer", status: .online, typingStatus: .stoppedTyping)
}
