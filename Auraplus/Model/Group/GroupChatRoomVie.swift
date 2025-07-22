import SwiftUI
import Combine

struct GroupChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    
    let groupId: Int
    let groupName: String
    
    @EnvironmentObject var session: SessionManager
    @StateObject private var socket: WebSocketManagerG
    @State private var members: [String] = []
    @State private var canDelete: Bool = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    init(groupId: Int, groupName: String) {
        self.groupId = groupId
        self.groupName = groupName
        _socket = StateObject(wrappedValue: WebSocketManagerG())
    }

    var body: some View {
        VStack {
            MessageListViewG(
                groupId: groupId,
                currentUserId: session.currentUser?.id ?? -1,
                webSocketManagerG: socket,
                senderUsername: session.currentUser?.username ?? "unknown",
                username: session.currentUser?.username,
                userid: session.currentUser?.id ?? 0
            )
            .toolbar(.hidden, for: .tabBar)
            .toolbar { groupHeaderToolbar() }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .bottom) {
                if let userId = session.currentUser?.id {
                    GroupMessageInputView(
                        groupId: groupId,
                        senderId: userId,
                        senderUsername: session.currentUser?.username,
                        webSocketManagerG: socket
                    )
                } else {
                    Text("Unable to load group chat. Please log in.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .onAppear {
            socket.setGroupId(groupId)
            socket.connect()
            checkIfUserCanDelete()
        }
        .onDisappear {
            socket.disconnect()
        }
        .alert("Error", isPresented: .constant(deleteError != nil), actions: {
            Button("OK", role: .cancel) { deleteError = nil }
        }, message: {
            Text(deleteError ?? "")
        })
    }

    @ToolbarContentBuilder
    private func groupHeaderToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }

                Image(systemName: "person.2.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.gray)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(groupName)
                        .font(.system(size: 17, weight: .bold))
                }

                Spacer()
            }
            .padding(.vertical, 6)
        }

        if canDelete {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        deleteGroupAction()
                    } label: {
                        Label("Delete Group", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func checkIfUserCanDelete() {
        guard let userId = session.currentUser?.id else { return }
        AuthService.shared.checkGroupCreator(groupId: groupId, createdBy: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let isCreator):
                    self.canDelete = isCreator
                case .failure(let error):
                    print("❌ Check creator failed: \(error.localizedDescription)")
                    self.canDelete = false
                }
            }
        }
    }

    private func deleteGroupAction() {
        guard let userId = session.currentUser?.id else { return }

        AuthService.shared.deleteGroup(groupId: groupId, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    dismiss() // ✅ Go back
                case .failure(let error):
                    deleteError = error.localizedDescription
                }
            }
        }
    }
}
