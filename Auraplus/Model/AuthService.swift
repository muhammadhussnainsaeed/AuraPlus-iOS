//
//  AuthService.swift
//  Auraplus
//
//  Created by Hussnain on 2/5/25.
//
import UIKit
import Foundation

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    //Register the User to the data base.
    func registerUser(_ data: RegisterRequest, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/register") else {
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
        guard var components = URLComponents(string: "http://192.168.100.31:8888/check-username") else {
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
        guard let url = URL(string: "http://192.168.100.31:8888/login") else { return }
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

        guard let url = URL(string: "http://192.168.100.31:8888/profile") else { return }
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
                    id: profile.id,
                    username: profile.username,
                    name: profile.name,
                    isonline: profile.is_online,
                    profileImageData: profile.profile_image
                )
                completion(user)
            }
        }
    }
    
    //Change the password of the account
    
    func updatePassword(username: String, oldPassword: String, newPassword: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/update_password") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let body: [String: String] = [
            "username": username,
            "old_password": oldPassword,
            "new_password": newPassword
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success("Password updated successfully."))
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["detail"] as? String {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        }.resume()
    }

    //Forget the Password

    struct SecurityAnswersRequest: Codable {
        let username: String
        let question1_answer: String
        let question2_answer: String
        let question3_answer: String
        let question4_answer: String
        let question5_answer: String
    }

    struct SecurityAnswersResponse: Codable {
        let success: Bool
        let message: String
    }

    func submitSecurityAnswers(
        username: String,
        q1: String,
        q2: String,
        q3: String,
        q4: String,
        q5: String,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (String) -> Void
    ) {
        guard let url = URL(string: "http://192.168.100.31:8888/check_security_answers") else {
            onFailure("Invalid URL.")
            return
        }

        let requestBody = SecurityAnswersRequest(
            username: username,
            question1_answer: q1,
            question2_answer: q2,
            question3_answer: q3,
            question4_answer: q4,
            question5_answer: q5
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            onFailure("Failed to encode request.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    onFailure("Network error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    onFailure("No response from server.")
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(SecurityAnswersResponse.self, from: data)
                DispatchQueue.main.async {
                    if decoded.success {
                        onSuccess()
                    } else {
                        onFailure(decoded.message)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    onFailure("Failed to parse response.")
                }
            }
        }.resume()
    }

    //Change the password in other words this will get username and password and change the password
    
    func updateForgottenPassword(username: String, newPassword: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/forgetupdate_password") else {
            onFailure("Invalid server URL.")
            return
        }

        let payload: [String: String] = [
            "username": username,
            "new_password": newPassword
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            onFailure("Failed to serialize request data.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    onFailure("Request error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    onFailure("Invalid response from server.")
                    return
                }

                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    let message = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    onFailure("Server error: \(message)")
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = json["success"] as? Bool {
                        if success {
                            onSuccess()
                        } else {
                            let message = json["message"] as? String ?? "Unknown failure"
                            onFailure(message)
                        }
                    } else {
                        onFailure("Invalid response format.")
                    }
                } catch {
                    onFailure("Failed to parse response.")
                }
            }
        }.resume()
    }
    
    //Update the Name and Profile pic
    
    struct UpdateUserPhotoRequest: Codable {
        let name: String
        let username: String
        let profile_image: String
    }
    
    func updateUserPhoto(name: String, username: String, imageBase64: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/update-user-photo") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = UpdateUserPhotoRequest(name: name, username: username, profile_image: imageBase64)
        
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 500)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion(.failure(NSError(domain: message, code: httpResponse.statusCode)))
                return
            }
            
            if let data = data,
               let result = try? JSONDecoder().decode([String: String].self, from: data),
               let message = result["message"] {
                completion(.success(message))
            } else {
                completion(.failure(NSError(domain: "Failed to parse response", code: 500)))
            }
        }
        
        task.resume()
    }
    
    //fetch the porfile picture and name of the user
    func getUserPhotoandName(username: String, completion: @escaping ((UIImage?, String?) -> Void)) {
        guard let url = URL(string: "http://192.168.100.31:8888/get-user-photo") else {
            completion(nil, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create JSON body manually to avoid encoding issues with dictionary
        let body: [String: String] = ["username": username]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let base64 = json["profile_image"] as? String,
                let imageData = Data(base64Encoded: base64),
                let image = UIImage(data: imageData),
                let name = json["name"] as? String
            else {
                completion(nil, nil)
                return
            }
            completion(image, name)
        }.resume()
    }

//update the online status of the user
    
    func updateOnlineStatus(username: String, isOnline: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/update-online-status") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "username": username,
            "is_online": isOnline
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //Fetch all the users that are avaiable on the AuraPlus platform
    func fetchContacts(excluding username: String, completion: @escaping ([[String: Any]]?) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/get-users") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["username": username])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let contacts = json["users"] as? [[String: Any]] else {
                completion(nil)
                return
            }
            completion(contacts)
        }.resume()
    }

    // create the group
    func createGroup(creatorUsername: String, groupName: String, members: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/create_group") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        let requestData: [String: Any] = [
            "creator_username": creatorUsername,
            "group_name": groupName,
            "members": members
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -1, userInfo: nil)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(()))
            } else {
                let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion(.failure(NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])))
            }
        }.resume()
    }

    //create the chat
    func createOrGetChat(
        with username: String,
        for currentUsername: String,
        completion: @escaping (Result<(chatID: Int, status: String), Error>) -> Void
    ) {
        guard let url = URL(string: "http://192.168.100.31:8888/create_or_get_chat") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let requestBody: [String: String] = [
            "username1": currentUsername,
            "username2": username
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let chatID = json["chat_id"] as? Int,
                   let status = json["status"] as? String {
                    completion(.success((chatID, status)))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //get all the chats
    struct UsernameRequest: Encodable {
        let username: String
    }
    func fetchChats(for username: String, completion: @escaping ([ChatPreview]?) -> Void) {
            guard let url = URL(string: "http://192.168.100.31:8888/get_user_chats") else {
                print("❌ Invalid URL")
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = UsernameRequest(username: username)
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                print("❌ Failed to encode body:", error)
                completion(nil)
                return
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Request error:", error)
                    completion(nil)
                    return
                }

                guard let data = data else {
                    print("❌ No data returned")
                    completion(nil)
                    return
                }

                do {
                    let chats = try JSONDecoder().decode([ChatPreview].self, from: data)
                    completion(chats)
                } catch {
                    print("❌ Failed to decode chats:", error)
                    print("Response body:", String(data: data, encoding: .utf8) ?? "nil")
                    completion(nil)
                }
            }
            task.resume()
        }
    
    //get online status
    
    struct OnlineStatusResponse: Decodable {
        let username: String
        let is_online: Bool
    }

    func fetchOnlineStatus(for username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let url = URL(string: "http://192.168.100.31:8888/get-online-status") else {
                print("❌ Invalid URL")
                completion(.failure(NSError(domain: "InvalidURL", code: 1)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: String] = ["username": username]
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error:", error)
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("❌ No data received")
                    completion(.failure(NSError(domain: "NoData", code: 2)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(OnlineStatusResponse.self, from: data)
                    completion(.success(decoded.is_online))
                } catch {
                    print("❌ Decoding error:", error)
                    completion(.failure(error))
                }
            }.resume()
        }

    //Get messages of specific chat
    func fetchMessages(chatId: Int, completion: @escaping ([Message]) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/messages/\(chatId)") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching messages:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let messages = try decoder.decode([Message].self, from: data)
                DispatchQueue.main.async {
                    completion(messages)
                }
            } catch {
                print("❌ Failed to decode messages:", error.localizedDescription)
            }
        }.resume()
    }

    
    //sent messages
    func sendMessageREST(_ message: MessageCreate, completion: @escaping (Message?) -> Void) {
        guard let url = URL(string: "http://192.168.100.31:8888/messages") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(message)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Error sending message:", error?.localizedDescription ?? "")
                return
            }
            if let result = try? JSONDecoder().decode(Message.self, from: data) {
                DispatchQueue.main.async {
                    completion(result)
                }
            } else {
                print("❌ Failed to decode POST response")
            }
        }.resume()
    }


}
