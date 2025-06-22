//
//  AuraplusApp.swift
//  Auraplus
//
//  Created by Hussnain on 7/3/25.
//

import SwiftUI

@main
struct AuraplusApp: App {
    @StateObject var session = SessionManager.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        session.restoreSession()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isLoggedIn {
                    HomeView()
                        .environmentObject(session)
                } else {
                    LoginView()
                        .environmentObject(session)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            guard let username = session.currentUser?.username else { return }

            switch newPhase {
            case .active:
                AuthService.shared.updateOnlineStatus(username: username, isOnline: true) { result in
                    if case .failure(let error) = result {
                        print("🟢 Online status error: \(error.localizedDescription)")
                    } else {
                        print("🟢 User is online")
                    }
                }

            case .background, .inactive:
                AuthService.shared.updateOnlineStatus(username: username, isOnline: false) { result in
                    if case .failure(let error) = result {
                        print("🔴 Offline status error: \(error.localizedDescription)")
                    } else {
                        print("🔴 User is offline")
                    }
                }

            default:
                break
            }
        }
    }
}
