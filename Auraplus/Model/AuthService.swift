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
        guard let url = URL(string: "http://192.168.10.3:8888/register") else {
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
        guard var components = URLComponents(string: "http://192.168.10.3:8888/check-username") else {
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
        
        func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
                guard let url = URL(string: "http://192.168.10.3:8000/login") else {
                    completion(.failure(NSError(domain: "Invalid URL", code: 0)))
                    return
                }

                let loginData = LoginRequest(username: username, password: password)

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                do {
                    request.httpBody = try JSONEncoder().encode(loginData)
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
                        completion(.failure(NSError(domain: "No Data", code: 0)))
                        return
                    }

                    do {
                        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                        completion(.success(decoded.access_token))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
        }
    }
