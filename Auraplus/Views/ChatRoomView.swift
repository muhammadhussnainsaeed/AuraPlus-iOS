import SwiftUI

struct ChatRoomView: View {
    var body: some View {
        MessageListView()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                chatHeaderToolbar()
            }
            .navigationBarTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                MessageInputView()
            }
    }
}

extension ChatRoomView {
    @ToolbarContentBuilder
    private func chatHeaderToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            ChatHeaderView(username: "Umer", status: .online, typingStatus: .stoppedTyping)
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomView()
    }
}
