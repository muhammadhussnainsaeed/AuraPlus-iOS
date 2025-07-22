import SwiftUI

struct ChatsView: View {
    @State private var searchText = ""
    @State private var showChatPartnerPickerView = false
    @State private var chats: [ChatPreview] = []
    @State private var groups: [GroupPreview] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasLoadedInitialData = false

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Chats")
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        newChatButton
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        leadingMenu
                    }
                }
                .sheet(isPresented: $showChatPartnerPickerView) {
                    ChatPartnerPickerView()
                        .environmentObject(SessionManager.shared)
                }
                .onAppear {
                    if !hasLoadedInitialData {
                        loadChats()
                    }
                }
                .refreshable {
                    await refreshChats()
                }
                .alert("Error", isPresented: errorBinding) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorMessage ?? "Unknown error occurred")
                }
        }
    }
    
    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        if isLoading && !hasLoadedInitialData {
            loadingView
        } else {
            chatsList
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Loading chats...")
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var chatsList: some View {
        List {
            chatsSection
            groupsSection
            emptyStateView
            footerView
        }
        .listStyle(PlainListStyle()) // Add this to prevent potential styling issues
    }
    
    @ViewBuilder
    private var chatsSection: some View {
        if !filteredChats.isEmpty {
            Section("Chats") {
                ForEach(filteredChats, id: \.id) { chat in
                    chatNavigationLink(for: chat)
                }
            }
        }
    }
    
    @ViewBuilder
    private var groupsSection: some View {
        if !filteredGroups.isEmpty {
            Section("Groups") {
                ForEach(filteredGroups, id: \.groupId) { group in
                    groupNavigationLink(for: group)
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        if filteredChats.isEmpty && filteredGroups.isEmpty && hasLoadedInitialData {
            VStack(spacing: 16) {
                if searchText.isEmpty {
                    Text("No chats or groups")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    
                    Button("Refresh") {
                        Task {
                            await refreshChats()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
    
    private var footerView: some View {
        HStack {
            Image(systemName: "lock.fill")
                .foregroundColor(.secondary)
            Text("Your personal messages are ")
                .foregroundColor(.secondary) +
            Text("end-to-end encrypted")
                .foregroundColor(.blue)
        }
        .font(.caption2)
        .padding(.horizontal)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    // MARK: - Navigation Links
    private func chatNavigationLink(for chat: ChatPreview) -> some View {
        NavigationLink(destination:
            ChatRoomView(
                name: chat.name,
                username: chat.withUsername,
                profilePictureBase64: chat.profilePictureBase64,
                currentUserId: chat.withUsernameId,
                chatId: chat.id
            )
        ) {
            ChatItemView(chat: chat)
        }
    }
    
    private func groupNavigationLink(for group: GroupPreview) -> some View {
        NavigationLink(destination:
            GroupChatRoomView(
                groupId: group.groupId,
                groupName: group.groupName
            )
        ) {
            GroupItemView(group: group)
        }
    }

    // MARK: - Filtered Data
    private var filteredChats: [ChatPreview] {
        guard !searchText.isEmpty else { return chats }
        return chats.filter { chat in
            chat.name.localizedCaseInsensitiveContains(searchText) ||
            chat.withUsername.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var filteredGroups: [GroupPreview] {
        guard !searchText.isEmpty else { return groups }
        return groups.filter { group in
            group.groupName.localizedCaseInsensitiveContains(searchText) ||
            (group.lastMessage?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }
    
    // MARK: - Computed Properties
    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )
    }
    
    private var newChatButton: some View {
        Button(action: { showChatPartnerPickerView = true }) {
            Image(systemName: "plus.circle.fill")
        }
    }
    
    private var leadingMenu: some View {
        Menu {
            Button(action: {
                // Add select chats functionality
            }) {
                Label("Select Chats", systemImage: "checkmark.circle")
            }
            // Add more menu items as needed
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    // MARK: - Data Loading
    private func loadChats() {
        guard let username = SessionManager.shared.currentUser?.username else {
            errorMessage = "User not logged in"
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            await loadChatsAsync(username: username)
        }
    }
    
    @MainActor
    private func loadChatsAsync(username: String) async {
        isLoading = true
        errorMessage = nil
        
        async let chatsResult = await fetchChatsAsync(username: username)
        try? await Task.sleep(for: .milliseconds(1000))
        async let groupsResult = await fetchGroupsAsync(username: username)
        
        let (fetchedChats, fetchedGroups) = await (chatsResult, groupsResult)
        
        var errors: [String] = []
        
        if let chats = fetchedChats {
            self.chats = chats
        } else {
            errors.append("Failed to load chats")
        }
        
        if let groups = fetchedGroups {
            self.groups = groups
        } else {
            errors.append("Failed to load groups")
        }
        
        isLoading = false
        hasLoadedInitialData = true
        
        if !errors.isEmpty {
            errorMessage = errors.joined(separator: " and ")
        }
    }
    
    private func fetchChatsAsync(username: String) async -> [ChatPreview]? {
        return await withCheckedContinuation { continuation in
            AuthService.shared.fetchChats(for: username) { chats in
                continuation.resume(returning: chats)
            }
        }
    }
    
    private func fetchGroupsAsync(username: String) async -> [GroupPreview]? {
        return await withCheckedContinuation { continuation in
            AuthService.shared.fetchGroups(for: username) { groups in
                continuation.resume(returning: groups)
            }
        }
    }
    
    @MainActor
    private func refreshChats() async {
        guard let username = SessionManager.shared.currentUser?.username else {
            errorMessage = "User not logged in"
            return
        }
        
        await loadChatsAsync(username: username)
    }
}

// MARK: - Preview
#Preview {
    ChatsView()
        .environmentObject(SessionManager.shared)
}
