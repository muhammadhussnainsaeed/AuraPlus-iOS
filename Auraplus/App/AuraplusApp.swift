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

    init() {
        session.restoreSession()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if session.isLoggedIn {
                    HomeView()
                        .environmentObject(session)
                } else {
                    LoginView()
                        .environmentObject(session)
                }
            }
        }
    }
}

