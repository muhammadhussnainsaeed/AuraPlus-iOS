//
//  UserListView.swift
//  Auraplus
//
//  Created by Hussnain on 6/4/25.
//

import SwiftUI

struct UserListView<Content: View>: View {
    private let user: UserContact
    private let trailingItems: Content

    init(user: UserContact, @ViewBuilder trailingItems: () -> Content = { EmptyView() }) {
        self.user = user
        self.trailingItems = trailingItems()
    }

    var body: some View {
        HStack {
            user.profileImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                .foregroundColor(.gray) // fallback color

            VStack(alignment: .leading) {
                Text(user.name)
                    .lineLimit(1)
                    .bold()

                Text("@\(user.username)")
                    .font(.caption)
//                    .foregroundColor(.gray)
            }

            Spacer()

            trailingItems
                .foregroundColor(.gray)
        }
        .padding(.vertical, 3)
    }
}

#Preview {
    let sampleImageBase64 = UIImage(systemName: "person.crop.circle.fill")?
        .pngData()?
        .base64EncodedString()

    let mockUser = UserContact(
        username: "hussnain",
        name: "Hussnain Saeed",
        profileImageBase64: sampleImageBase64
    )

    return UserListView(user: mockUser) {
        Image(systemName: "chevron.right")
    }
}
