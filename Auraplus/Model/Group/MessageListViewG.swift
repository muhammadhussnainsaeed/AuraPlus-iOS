import SwiftUI

struct MessageListViewG: UIViewControllerRepresentable {
    let groupId: Int
    let currentUserId: Int
    let webSocketManagerG: WebSocketManagerG
    let senderUsername: String?
    let username: String?
    let userid: Int

    func makeUIViewController(context: Context) -> GroupMessageListController {
        let vc = GroupMessageListController()
        vc.groupId = groupId
        vc.currentUserId = currentUserId
        vc.webSocketManagerG = webSocketManagerG
        vc.username = username
        vc.senderUsername = senderUsername
        vc.userid = userid
        return vc
    }

    func updateUIViewController(_ uiViewController: GroupMessageListController, context: Context) {}
}
