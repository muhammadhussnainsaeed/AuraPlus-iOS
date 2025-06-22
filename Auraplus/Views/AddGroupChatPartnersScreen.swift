import SwiftUI
import UIKit

struct AddGroupChatPartnersScreen: View {
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var users: [UserContact] = []
    @State private var selectedUsers: [UserContact] = []

    var body: some View {
        VStack(spacing: 0) {
            // Selected users scroll view
            if !selectedUsers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(selectedUsers, id: \.username) { user in
                            VStack {
                                ZStack(alignment: .topTrailing) {
                                    user.profileImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())

                                    if user.username != session.currentUser?.username {
                                        Button(action: {
                                            if let index = selectedUsers.firstIndex(where: { $0.username == user.username }) {
                                                selectedUsers.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 5, y: -5)
                                    }
                                }

                                Text(user.username == session.currentUser?.username ? "You" : user.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
            }

            Divider()

            // User list
            List {
                ForEach(filteredUsers) { user in
                    Button(action: {
                        toggleSelection(for: user)
                    }) {
                        HStack {
                            UserListView(user: user)
                            Spacer()
                            Image(systemName: isSelected(user) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
            .listStyle(.plain)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search name or number")
        .navigationTitle("\(selectedUsers.count)/6")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                    if selectedUsers.count >= 3 && selectedUsers.count <= 6 {
                        NavigationLink(destination: NewGroupDetailsScreen(selectedMembers: selectedUsers)) {
                            Text("Next")
                                .foregroundColor(.blue)
                                .bold()
                        }
                    }
                }
        }
        .onAppear(perform: loadUsers)
    }

    // MARK: - Load Users
    private func loadUsers() {
        guard let currentUser = session.currentUser else { return }

        // Convert Data to Base64 string
        let imageBase64 = currentUser.profileImageData?.base64EncodedString()

        // Create UserContact for yourself
        let selfUser = UserContact(
            username: currentUser.username,
            name: currentUser.name,
            profileImageBase64: imageBase64
        )

        // Add yourself to selectedUsers initially
        self.selectedUsers = [selfUser]

        // Fetch other users
        AuthService.shared.fetchContacts(excluding: currentUser.username) { fetched in
            DispatchQueue.main.async {
                self.users = (fetched ?? []).compactMap { dict in
                    guard
                        let username = dict["username"] as? String,
                        let name = dict["name"] as? String
                    else {
                        return nil
                    }

                    return UserContact(
                        username: username,
                        name: name,
                        profileImageBase64: dict["profile_image"] as? String
                    )
                }
            }
        }
    }


    // MARK: - Helpers
    private func isSelected(_ user: UserContact) -> Bool {
        selectedUsers.contains(where: { $0.username == user.username })
    }

    private func toggleSelection(for user: UserContact) {
        if user.username == session.currentUser?.username {
            return // Prevent deselecting self
        }

        if isSelected(user) {
            selectedUsers.removeAll { $0.username == user.username }
        } else if selectedUsers.count < 6 {
            selectedUsers.append(user)
        }
    }

    var filteredUsers: [UserContact] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter {
                $0.username.lowercased().contains(searchText.lowercased()) ||
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddGroupChatPartnersScreen()
            .environmentObject(SessionManager.shared)
    }
}
