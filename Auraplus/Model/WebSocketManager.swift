import Foundation

// MARK: - Message Model (outgoing)
struct WebSocketMessage: Codable {
    let chat_id: Int
    let sender_id: Int
    let content: String?
    let media_url: String?
    let message_type: String
}

// MARK: - WebSocket Manager
class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://192.168.100.8:8888/ws/chat")!
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
        let encryptedContent: String = content.isEmpty ? "" : (AESHelper.shared.encrypt(message: content) ?? "")
        let message = WebSocketMessage(
            chat_id: chatId,
            sender_id: senderId,
            content: encryptedContent,
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

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.receiveMessages()
                }

            case .success(let message):
                switch message {
                case .string(let text):
                    print("📩 Encrypted JSON Received:", text)

                    // Step 1: Decode JSON with encrypted content
                    if let decoded = try? JSONDecoder().decode(Message.self, from: Data(text.utf8)) {

                        // Step 2: Decrypt the content
                        var decryptedContent: String? = nil
                        if let encrypted = decoded.content, !encrypted.isEmpty {
                            decryptedContent = AESHelper.shared.decrypt(base64CipherText: encrypted)
                        } else {
                            decryptedContent = decoded.content
                        }
                        // Step 3: Create a new decrypted message instance
                        let finalMessage = Message(
                            id: decoded.id,
                            chat_id: decoded.chat_id,
                            sender_id: decoded.sender_id,
                            username: decoded.username,
                            content: decryptedContent,
                            media_url: decoded.media_url,
                            message_type: decoded.message_type,
                            time_stamp: decoded.time_stamp
                        )

                        // Step 4: Filter by chat ID and update
                        if finalMessage.chat_id == self.currentChatId {
                            DispatchQueue.main.async {
                                self.newIncomingMessage = finalMessage
                            }
                        } else {
                            print("⚠️ Chat ID doesn't match")
                        }

                    } else {
                        print("⚠️ Message JSON decoding failed")
                    }

                case .data(let data):
                    print("📦 Binary data received:", data)

                @unknown default:
                    print("⚠️ Unknown message type")
                }

                self.receiveMessages() // Keep listening
            }
        }
    }
}
