//
//  SettingsView.swift
//  Auraplus
//
//  Created by Hussnain on 8/3/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionManager
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        EditProfileView()
                            .environmentObject(SessionManager.shared)
                    } label: {
                        HStack {
                            // Display user image from Data
                            if let imageData = session.currentUser?.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 50))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.currentUser?.name ?? "User")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)

                                Text("@\(session.currentUser?.username ?? "user")")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 3)
                        }
                    }
                }

                Section("Account") {
                    NavigationLink {
                        ChangePasswordView()
                            .environmentObject(SessionManager.shared)
                    } label: {
                        SettingItemView(title: "Account",
                                        icon: "key.fill", color: .green)
                    }

                    Button(action: {
                        
                        guard let username = session.currentUser?.username else { return }
                        AuthService.shared.updateOnlineStatus(username: username, isOnline: false) { result in
                            if case .failure(let error) = result {
                                print("🔴 Offline status error: \(error.localizedDescription)")
                            } else {
                                print("🔴 User is offline")
                            }
                        }
                        session.logout()
                        
                    }) {
                        SettingItemView(title: "Logout",
                                        icon: "exclamationmark.triangle.fill", color: .red)
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SessionManager.shared)  // Inject your singleton here
}

