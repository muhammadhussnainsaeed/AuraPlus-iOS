import SwiftUI

struct ChatPartnerPickerView: View {
    @State private var searchText = ""
    @State private var users: [UserContact] = []
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedChatID: Int?
    @State private var selectedUser: UserContact?

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // Header option (like "New Group")
                    Section {
                        ForEach(ChatPartnerPickerOption.allCases) { item in
                            HeaderItemView(item: item)
                        }
                    }

                    // Users list
                    Section(header: Text("Users available on Aura+").bold()) {
                        ForEach(filteredUsers) { user in
                            Button {
                                createChat(with: user)
                            } label: {
                                UserListView(user: user)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search for username")

            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                trailingNavItem()
            }
            .onAppear(perform: loadUsers)
        }
    }


    // MARK: - Load Users from API
    private func loadUsers() {
        guard let currentUsername = session.currentUser?.username else { return }

        AuthService.shared.fetchContacts(excluding: currentUsername) { fetched in
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

    // MARK: - Create Chat
    private func createChat(with user: UserContact) {
        guard let currentUsername = session.currentUser?.username else { return }

        AuthService.shared.createOrGetChat(
            with: user.username,
            for: currentUsername
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (chatID, _)):
                    // Just dismiss, don't navigate
                    dismiss()
                case .failure(let error):
                    print("❌ Error creating chat:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Filtered Search Results
    var filteredUsers: [UserContact] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter {
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - Toolbar
extension ChatPartnerPickerView {
    @ToolbarContentBuilder
    private func trailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.callout)
                    .foregroundColor(.blue)
                    .bold()
                    .padding()
            }
        }
    }
}

// MARK: - Header Item View
extension ChatPartnerPickerView {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOption
        @State private var isActive = false

        var body: some View {
            NavigationLink(destination: AddGroupChatPartnersScreen(), isActive: $isActive) {
                Button {
                    isActive = true
                } label: {
                    HStack {
                        Image(systemName: item.imageName)
                            .frame(width: 35, height: 35)
                        Text(item.title)
                            .foregroundColor(.primary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Chat Options Enum
enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "New Group"

    var id: String { rawValue }

    var title: String { rawValue }

    var imageName: String {
        switch self {
        case .newGroup: return "person.2.badge.plus.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    ChatPartnerPickerView()
        .environmentObject(SessionManager.shared)
}
