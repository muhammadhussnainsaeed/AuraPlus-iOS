//
//  WebSocketManagerG.swift
//  Auraplus
//
//  Created by Hussnain on 23/6/25.
//

import Foundation

// MARK: - Message Model (Outgoing)
struct WebSocketMessageG: Codable {
    let chat_id: Int
    let sender_id: Int
    let content: String?
    let media_url: String?
    let message_type: String  // "text", "image", "audio", etc.
}

import Foundation

class WebSocketManagerG: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://192.168.100.8:8888/ws/group_chat")!
    private let session = URLSession(configuration: .default)

    @Published var newIncomingMessage: GroupMessage?

    private var currentGroupId: Int?

    init(groupId: Int? = nil) {
        self.currentGroupId = groupId
    }

    func setGroupId(_ id: Int) {
        self.currentGroupId = id
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

    func sendMessage(groupId: Int, senderId: Int, content: String?, mediaURL: String? = nil, messageType: String = "text") {
        let encryptedContent: String? = {
            guard let text = content, !text.isEmpty else { return content }
            return AESHelper.shared.encrypt(message: text)
        }()

        let message = WebSocketMessageG(
            chat_id: groupId,
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
                    print("❌ Group message send failed:", error.localizedDescription)
                } else {
                    print("✅ Group message sent")
                }
            }
        } catch {
            print("❌ Group message encoding error:", error)
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
                    print("📩 Group Encrypted JSON Received:", text)

                    // Step 1: Decode JSON with encrypted content
                    if let decoded = try? JSONDecoder().decode(GroupMessage.self, from: Data(text.utf8)) {

                        // Step 2: Decrypt the content (if present)
                        var decryptedContent: String? = nil
                        if let encrypted = decoded.content, !encrypted.isEmpty {
                            decryptedContent = AESHelper.shared.decrypt(base64CipherText: encrypted)
                        } else {
                            decryptedContent = decoded.content
                        }

                        // Step 3: Recreate a new instance with decrypted content
                        let finalMessage = GroupMessage(
                            id: decoded.id,
                            group_id: decoded.group_id,
                            sender_id: decoded.sender_id,
                            username: decoded.username,
                            content: decryptedContent,
                            media_url: decoded.media_url,
                            message_type: decoded.message_type,
                            time_stamp: decoded.time_stamp
                        )

                        // Step 4: Check group match and update UI
                        if finalMessage.group_id == self.currentGroupId {
                            DispatchQueue.main.async {
                                self.newIncomingMessage = finalMessage
                            }
                        } else {
                            print("⚠️ Group ID doesn't match")
                        }

                    } else {
                        print("⚠️ Group JSON decoding failed")
                    }

                case .data(let data):
                    print("📦 Binary data received in group:", data)

                @unknown default:
                    print("⚠️ Unknown group message type")
                }

                self.receiveMessages() // Keep listening
            }
        }
    }
}
