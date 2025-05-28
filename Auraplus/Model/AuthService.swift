//
//  AuthService.swift
//  Auraplus
//
//  Created by Hussnain on 2/5/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    //Register the User to the data base.
    func registerUser(_ data: RegisterRequest, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "http://192.168.100.8:8888/register") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(data)
        } catch {
            completion(false, "Encoding error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                completion(true, "Registration successful")
            } else {
                completion(false, "Registration failed: Status \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    //checks for the username in the database
    struct UsernameCheckResponse: Decodable {
        let available: Bool
        let message: String
    }
    
    func checkUsernameAvailable(username: String, completion: @escaping (Bool) -> Void) {
        guard var components = URLComponents(string: "http://192.168.100.8:8888/check-username") else {
            completion(false)
            return
        }
        
        components.queryItems = [URLQueryItem(name: "username", value: username)]
        
        guard let url = components.url else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("-----Error checking username-----: \(error)")
                completion(false)
                return
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(UsernameCheckResponse.self, from: data)
                print("Message from server: \(result.message)")
                completion(result.available)
            } catch {
                print("Decode error: \(error)")
                completion(false)
            }
        }.resume()
    }
    
    
    
    
    //Login the user
    struct LoginRequest: Codable {
        let username: String
        let password: String
    }

    struct LoginResponse: Codable {
        let access_token: String
        let token_type: String
    }

    struct UserProfile: Codable {
        let id: Int
        let username: String
        let name: String
        let profile_image: Data?
        let question1_answer: String
        let question2_answer: String
        let question3_answer: String
        let question4_answer: String
        let question5_answer: String
        let is_online: Bool
        let created_at: String
    }

    func login(username: String, password: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://192.168.100.8:8888/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(username: username, password: password)
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            UserDefaults.standard.set(loginResponse.access_token, forKey: "accessToken")
            DispatchQueue.main.async {
                completion(loginResponse.access_token)
            }
        }.resume()
    }
    
    //Get the data of the user from the database
    func getProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            completion(nil)
            return
        }

        guard let url = URL(string: "http://192.168.100.8:8888/profile") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if let decoded = try? JSONDecoder().decode([String: UserProfile].self, from: data),
               let user = decoded["user"] {
                DispatchQueue.main.async {
                    completion(user)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    //Login with Session
    func loginWithSession(username: String, password: String, completion: @escaping (User?) -> Void) {
        // 1. Login using FastAPI and get the access token from the database
        login(username: username, password: password) { token in
            guard token != nil else {
                completion(nil)
                return
            }

            // 2. Now get the full user profile from the database (with token auth)
            self.getProfile { userProfile in
                guard let profile = userProfile else {
                    completion(nil)
                    return
                }

                // 3. Create app-specific User model (for session)
                let user = User(
                    id: String(profile.id),
                    username: profile.username,
                    name: profile.name,
                    isonline: profile.is_online,
                    profileImageData: profile.profile_image
                )
                completion(user)
            }
        }
    }
}
