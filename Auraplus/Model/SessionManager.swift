//
//  SessionManager.swift
//  Auraplus
//
//  Created by Hussnain on 22/5/25.
//

import Foundation

class SessionManager: ObservableObject {
    static let shared = SessionManager()

    @Published var currentUser: User? = nil
    @Published var isLoggedIn: Bool = false

    private let userDefaultsKey = "currentUserData"

    func login(username: String, password: String) {
        AuthService.shared.loginWithSession(username: username, password: password) { user in
            DispatchQueue.main.async {
                if let user = user {
                    self.currentUser = user
                    self.isLoggedIn = true
                    self.saveUserToDefaults(user: user)
                } else {
                    self.isLoggedIn = false
                    self.clearUserFromDefaults()
                }
            }
        }
    }

    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        clearUserFromDefaults()
    }

    func restoreSession() {
        guard let userData = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            self.isLoggedIn = false
            return
        }

        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            self.currentUser = user
            self.isLoggedIn = true
        } catch {
            print("Failed to decode user from UserDefaults:", error)
            self.isLoggedIn = false
        }
    }

    private func saveUserToDefaults(user: User) {
        do {
            let encodedData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Failed to encode user for UserDefaults:", error)
        }
    }

    private func clearUserFromDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}


