import Foundation

// MARK: - Message Model (outgoing)
struct WebSocketMessage: Codable {
    let chat_id: Int
    let sender_id: Int
    let content: String
    let media_url: String?
    let message_type: String
}

// MARK: - WebSocket Manager
class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://192.168.100.31:8888/ws/chat")!
    private let session = URLSession(configuration: .default)

    @Published var newIncomingMessage: Message?
    
    private var currentChatId: Int?
    
    init(chatId: Int? = nil) {
            self.currentChatId = chatId
        }

        func setChatId(_ id: Int) {
            self.currentChatId = id
        }

    func connect() {
        let request = URLRequest(url: url)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    func sendMessage(chatId: Int, senderId: Int, content: String, mediaURL: String? = nil, messageType: String = "text") {
        let message = WebSocketMessage(
            chat_id: chatId,
            sender_id: senderId,
            content: content,
            media_url: mediaURL,
            message_type: messageType
        )

        do {
            let jsonData = try JSONEncoder().encode(message)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ Send failed:", error.localizedDescription)
                } else {
                    print("✅ Message sent")
                }
            }
        } catch {
            print("❌ Encoding error:", error)
        }
    }

    private func receiveMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("❌ Receive error:", error.localizedDescription)

                // Try reconnecting or retrying after a small delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.receiveMessages()
                }

            case .success(let message):
                switch message {
                case .string(let text):
                    print("📩 Received text:", text)
                    if let data = text.data(using: .utf8),
                       let decoded = try? JSONDecoder().decode(Message.self, from: data),
                       decoded.chat_id == self.currentChatId {
                        DispatchQueue.main.async {
                            self.newIncomingMessage = decoded
                        }
                    } else {
                        print("⚠️ Failed to decode or filtered out message")
                    }
                case .data(let data):
                    print("📦 Received binary data:", data)
                @unknown default:
                    print("⚠️ Unknown message type")
                }

                // 👇 Listen for the next message
                self.receiveMessages()
            }
        }
    }
}
