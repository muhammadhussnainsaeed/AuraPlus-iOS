import SwiftUI

struct ChatRoomView: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<12) { _ in
                    Text("sample")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                }
            }
        }
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
