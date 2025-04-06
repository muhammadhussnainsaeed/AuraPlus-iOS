import SwiftUI

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        MessageListView()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                chatHeaderToolbar()
            }
            .navigationTitle("") // override inherited "Chats"
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .bottom) {
                MessageInputView()
            }
    }
}

extension ChatRoomView {
    @ToolbarContentBuilder
    private func chatHeaderToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                ChatHeaderView(username: "Umer", status: .online, typingStatus: .stoppedTyping)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatRoomView()
    }
}
