import Foundation
import UIKit

import Foundation

class NetworkService {
    static let shared = NetworkService()

    func uploadMedia(username: String, fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "http://192.168.100.31:8888/upload-media/")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add username field
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"username\"\r\n\r\n")
        body.append("\(username)\r\n")

        // Add file field
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/m4a"  // Change based on actual type

        if let fileData = try? Data(contentsOf: fileURL) {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let urlString = String(data: data, encoding: .utf8) {
                completion(.success(urlString))
            } else {
                completion(.failure(NSError(domain: "upload", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown upload error."])))
            }
        }.resume()
    }
    
    //to download the media
    func downloadMedia(linkPath: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Directly use the IP and port in the URL string
        guard let encodedLink = linkPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://192.168.100.31:8888/get-media/?link=\(encodedLink)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempURL = tempURL else {
                completion(.failure(NSError(domain: "No file", code: 0)))
                return
            }

            do {
                let filename = URL(string: linkPath)?.lastPathComponent ?? UUID().uuidString
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let savedURL = documentsURL.appendingPathComponent(filename)

                // Remove old file if it exists
                if FileManager.default.fileExists(atPath: savedURL.path) {
                    try FileManager.default.removeItem(at: savedURL)
                }

                try FileManager.default.moveItem(at: tempURL, to: savedURL)

                DispatchQueue.main.async {
                    completion(.success(savedURL))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
}


    private func mimeTypeFor(pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "m4a": return "audio/m4a"
        case "mp4": return "video/mp4"
        default: return "application/octet-stream"
        }
    }

// MARK: - Data extension
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
