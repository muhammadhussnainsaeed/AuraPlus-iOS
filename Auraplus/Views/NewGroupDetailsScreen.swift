import SwiftUI
import UIKit

struct NewGroupDetailsScreen: View {
    let selectedMembers: [UserContact]

    @State private var groupName: String = ""
    @EnvironmentObject var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    @State private var isCreating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            // Group Name Input
            TextField("Enter the group name", text: $groupName)
                .disableAutocorrection(true)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

            // Members Section
            Text("MEMBERS: \(selectedMembers.count)")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(selectedMembers, id: \.username) { member in
                        HStack(spacing: 12) {
                            member.profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())

                            Text(member.name)
                                .font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create") {
                    createGroup()
                }
                .foregroundColor(.blue)
                .bold()
                .disabled(isCreating)
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { _ in errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    // MARK: - Create Group Function
    private func createGroup() {
        guard let creatorUsername = session.currentUser?.username else {
            errorMessage = "Missing session data"
            return
        }

        // Filter out current user from selectedMembers (in case they exist)
        let membersForAPI = selectedMembers
            .filter { $0.username != creatorUsername }
            .map { $0.username }

        isCreating = true

        AuthService.shared.createGroup(
            creatorUsername: creatorUsername,
            groupName: groupName.isEmpty ? "Unnamed Group" : groupName,
            members: membersForAPI
        ) { result in
            DispatchQueue.main.async {
                isCreating = false
                switch result {
                case .success:
                    dismissToRoot()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Dismiss to Root View
    private func dismissToRoot() {
        // This uses DispatchQueue to dismiss twice — effectively pops to root
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

#Preview {
    let sampleImageBase64 = UIImage(systemName: "person.fill")?
        .pngData()?
        .base64EncodedString()

    let mockUsers = [
        UserContact(username: "john", name: "John Doe", profileImageBase64: sampleImageBase64),
        UserContact(username: "jane", name: "Jane Smith", profileImageBase64: sampleImageBase64),
        UserContact(username: "alice", name: "Alice Johnson", profileImageBase64: sampleImageBase64)
    ]

    return NavigationStack {
        NewGroupDetailsScreen(selectedMembers: mockUsers)
            .environmentObject(SessionManager.shared)
    }
}
