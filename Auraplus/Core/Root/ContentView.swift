//
//  ContentView.swift
//  Auraplus
//
// Created by Hussnain on 7/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var session = SessionManager.shared

        var body: some View {
            Group {
                if session.isLoggedIn {
                    HomeView()
                } else {
                    NavigationStack{
                        LoginView()
                    }
                }
            }
            .onAppear {
                autoLoginIfNeeded()
            }
        }

        func autoLoginIfNeeded() {
            if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                // Try auto-login with stored token
                AuthService.shared.getProfile { profile in
                    if let profile = profile {
                        DispatchQueue.main.async {
                            session.currentUser = User(
                                id: profile.id,
                                username: profile.username,
                                name: profile.name,
                                isonline: profile.is_online,
                                profileImageData: profile.profile_image
                            )
                            session.isLoggedIn = true
                        }
                    }
                }
            }
        }
}

#Preview {
    ContentView()
}
