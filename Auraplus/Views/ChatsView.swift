import SwiftUI

struct ChatsView: View {
    @State private var searchText = ""
    @State private var showChatPartnerPickerView = false
    @State private var chats: [ChatPreview] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading chats...")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else if chats.isEmpty && !searchText.isEmpty {
                    Text("No chats found")
                        .foregroundColor(.gray)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredChats) { chat in
                        NavigationLink {
                            ChatRoomView(
                                name: chat.name,
                                username: chat.withUsername,
                                profilePictureBase64: chat.profilePictureBase64,
                                currentUserId: chat.withUsernameId, chatId: chat.id
                            )
                        } label: {
                            ChatItemView(chat: chat)
                        }
                    }
                }

                inboxFooterView()
                    .listRowSeparator(.hidden)
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    newChatButton()
                }
                ToolbarItem(placement: .topBarLeading) {
                    leadingMenu()
                }
            }
            .sheet(isPresented: $showChatPartnerPickerView) {
                ChatPartnerPickerView()
                    .environmentObject(SessionManager.shared)
            }
            .onAppear {
                loadChats()
            }
            .refreshable {
                loadChats()
            }
            .alert("Error", isPresented: Binding(get: {
                errorMessage != nil
            }, set: { _ in
                errorMessage = nil
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Filtered Chat Search
    private var filteredChats: [ChatPreview] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.withUsername.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // MARK: - Load Chats from API
    private func loadChats() {
        guard let username = SessionManager.shared.currentUser?.username else {
            self.errorMessage = "User not logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        AuthService.shared.fetchChats(for: username) { chatList in
            DispatchQueue.main.async {
                self.isLoading = false
                if let chats = chatList {
                    self.chats = chats
                } else {
                    self.errorMessage = "Failed to load chats"
                }
            }
        }
    }

    // MARK: - Footer View
    private func inboxFooterView() -> some View {
        HStack {
            Image(systemName: "lock.fill")
            (
                Text("Your personal messages are ") +
                Text("end-to-end encrypted").foregroundColor(.blue)
            )
        }
        .foregroundColor(.gray)
        .font(.caption2)
        .padding(.horizontal)
    }

    // MARK: - Toolbar Buttons
    private func newChatButton() -> some View {
        Button {
            showChatPartnerPickerView = true
        } label: {
            Image(systemName: "plus.circle.fill")
        }
    }

    private func leadingMenu() -> some View {
        Menu {
            Button {
                // Add action here
            } label: {
                Label("Select Chats", systemImage: "checkmark.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// MARK: - Preview
#Preview {
    ChatsView()
        .environmentObject(SessionManager.shared)
}
