import SwiftUI

struct ChatRoomView: View {
    var body: some View {
        MessageListView()
        .toolbar(.hidden,for: .tabBar)
        .toolbar{
            leadingNavItems()
        }
        .safeAreaInset(edge: .bottom){
            MessageInputView()
        }
    }
}

extension ChatRoomView {
    @ToolbarContentBuilder
    private func leadingNavItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 30))
                Text("Umer")
                    .bold()
            }
        }
    }
}

#Preview {
    ChatRoomView()
}
