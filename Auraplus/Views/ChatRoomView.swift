import SwiftUI
import Combine

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    
    let name: String
    let username: String
    let profilePictureBase64: String?
    let currentUserId: Int
    let chatId: Int
    
    @State private var isTyping = false
    @State private var userStatus: UserStatus = .offline
    @EnvironmentObject var session: SessionManager
    @State private var statusTimer: AnyCancellable?
    @State private var lastTypingDate: Date?
    @State private var lastOnlineStatusDate: Date?
    @StateObject private var socket: WebSocketManager
    
    // Debounce timers
    @State private var typingDebounceTimer: Timer?
    @State private var statusDebounceTimer: Timer?
    
    init(name: String, username: String, profilePictureBase64: String?, currentUserId: Int, chatId: Int) {
        self.name = name
        self.username = username
        self.profilePictureBase64 = profilePictureBase64
        self.currentUserId = currentUserId
        self.chatId = chatId
        _socket = StateObject(wrappedValue: WebSocketManager(chatId: chatId))
    }
    
    var body: some View {
        VStack {
            MessageListView(
                chatId: chatId,
                currentUserId: currentUserId,
                webSocketManager: socket,
                senderUsername: username,
                username: session.currentUser?.username,
                userid: session.currentUser?.id ?? 0
            )
            .toolbar(.hidden, for: .tabBar)
            .toolbar { chatHeaderToolbar() }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .bottom) {
                if let userId = session.currentUser?.id {
                    MessageInputView(
                        chatId: chatId,
                        senderId: userId,
                        senderUsername: session.currentUser?.username,
                        webSocketManager: socket
                    )
                } else {
                    Text("Unable to load chat. Please log in.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            socket.connect()
            startStatusUpdateLoop()
            // Fetch initial status immediately
            fetchOnlineStatus(initialFetch: true)
            fetchTypingStatus(initialFetch: true)
        }
        .onDisappear {
            socket.disconnect()
            statusTimer?.cancel()
            typingDebounceTimer?.invalidate()
            statusDebounceTimer?.invalidate()
        }
    }
    
    // MARK: - Timer Loop
    private func startStatusUpdateLoop() {
        statusTimer?.cancel() // Cancel any existing timer
        
        statusTimer = Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                fetchOnlineStatus()
                fetchTypingStatus()
                checkTypingTimeout()
            }
    }
    
    // MARK: - Fetch Status with Debouncing
    private func fetchOnlineStatus(initialFetch: Bool = false) {
        // Debounce rapid status updates
        if !initialFetch {
            statusDebounceTimer?.invalidate()
            statusDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                actuallyFetchOnlineStatus()
            }
        } else {
            actuallyFetchOnlineStatus()
        }
    }
    
    private func actuallyFetchOnlineStatus() {
        // Only update if last update was more than 5 seconds ago
        if let lastDate = lastOnlineStatusDate, Date().timeIntervalSince(lastDate) < 5 && userStatus != .offline {
            return
        }
        
        AuthService.shared.fetchOnlineStatus(for: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isOnline):
                    let newStatus: UserStatus = isOnline ? .online : .offline
                    if newStatus != userStatus {
                        userStatus = newStatus
                        lastOnlineStatusDate = Date()
                    }
                case .failure:
                    // Only go offline if we haven't had a successful update in a while
                    if let lastDate = lastOnlineStatusDate, Date().timeIntervalSince(lastDate) > 10 {
                        userStatus = .offline
                    }
                }
            }
        }
    }
    
    private func fetchTypingStatus(initialFetch: Bool = false) {
        AuthService.shared.getTypingStatus(chatID: chatId, username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let typing):
                    handleTypingStatusUpdate(isTyping: typing)
                case .failure(let error):
                    print("❌ Typing fetch failed: \(error.localizedDescription)")
                    // Don't immediately set to false on failure - wait for timeout
                }
            }
        }
    }
    
    private func handleTypingStatusUpdate(isTyping newTypingStatus: Bool) {
        if newTypingStatus {
            if !isTyping {
                isTyping = true
                lastTypingDate = Date()
            } else {
                // Refresh last typing date if still typing
                lastTypingDate = Date()
            }
        } else {
            // Only stop showing typing if we've received a "not typing" status
            // and it's been more than 1 second since last typing activity
            if let lastDate = lastTypingDate, Date().timeIntervalSince(lastDate) > 1 {
                isTyping = false
                lastTypingDate = nil
            }
        }
    }
    
    // MARK: - Auto-clear Typing
    private func checkTypingTimeout() {
        if isTyping, let lastDate = lastTypingDate {
            let elapsed = Date().timeIntervalSince(lastDate)
            if elapsed > 3.0 { // Increased timeout to 3 seconds
                print("⌛ Typing timeout reached. Auto-clearing.")
                isTyping = false
                lastTypingDate = nil
            }
        }
    }
    
    // MARK: - Header
    @ToolbarContentBuilder
    private func chatHeaderToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left").foregroundColor(.blue)
                }
                ChatHeaderView(
                    name: name,
                    username: username,
                    profilePictureBase64: profilePictureBase64,
                    status: userStatus,
                    typingStatus: isTyping ? .typing : .stoppedTyping
                )
            }
        }
    }
}
