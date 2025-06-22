import SwiftUI
import Combine

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss

    let name: String
    let username: String
    let profilePictureBase64: String?
    let currentUserId: Int
    let chatId: Int

    @State private var userStatus: UserStatus = .offline
    @EnvironmentObject var session: SessionManager
    @State private var timer: AnyCancellable?
    @StateObject private var socket: WebSocketManager

    init(name: String, username: String, profilePictureBase64: String?, currentUserId: Int, chatId: Int) {
        self.name = name
        self.username = username
        self.profilePictureBase64 = profilePictureBase64
        self.currentUserId = currentUserId
        self.chatId = chatId
        _socket = StateObject(wrappedValue: WebSocketManager())
    }

    var body: some View {
        VStack {
            MessageListView(chatId: chatId, currentUserId: currentUserId, webSocketManager: socket, senderUsername: username, username: session.currentUser?.username)
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
            socket.setChatId(chatId)
            socket.connect()
            startOnlineStatusTimer()
        }
        .onDisappear {
            socket.disconnect()
            timer?.cancel()
        }
    }

    private func startOnlineStatusTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                AuthService.shared.fetchOnlineStatus(for: username) { result in
                    DispatchQueue.main.async {
                        userStatus = (try? result.get()) == true ? .online : .offline
                    }
                }
            }
    }

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
                    typingStatus: .stoppedTyping
                )
            }
        }
    }
}



//#Preview {
//    NavigationStack {
//        ChatRoomView(
//            name: "Ali Raza",
//            username: "ali123",
//            profilePictureBase64: nil,
//            currentUserId: 1,
//            chatId: 1
//        )
//    }
//}
