//
//  MessageListView.swift
//  Auraplus
//
//  Created by Hussnain on 22/3/25.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    let chatId: Int
    let currentUserId: Int
    let webSocketManager: WebSocketManager
    let senderUsername: String
    let username: String?
    let userid: Int

    func makeUIViewController(context: Context) -> MessageListController {
        let vc = MessageListController()
        vc.chatId = chatId
        vc.currentUserId = currentUserId
        vc.webSocketManager = webSocketManager
        vc.username = username
        vc.userid = userid
        return vc
    }

    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {}
}

//#Preview {
//    let dummySocket = WebSocketManager(currentUserId: 1, currentChatId: 1)
//    MessageListView(chatId: 1, currentUserId: 1, webSocketManager: dummySocket,senderUsername: "", username: "test")
//}
