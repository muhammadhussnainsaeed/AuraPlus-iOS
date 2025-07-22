import SwiftUI
import AVKit

struct MediaViewerView: View {
    let mediaURL: URL
    let type: MessageType
    @Environment(\.dismiss) var dismiss
    
    @State private var debugInfo = "Loading..."

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                // Debug info at the top
                VStack {
                    Text("DEBUG INFO")
                        .foregroundColor(.yellow)
                        .font(.headline)
                    Text(debugInfo)
                        .foregroundColor(.white)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .background(Color.red.opacity(0.3))
                .cornerRadius(10)
                .padding()
                
                Spacer()
                
                // Media content
                Group {
                    switch type {
                    case .photo:
                        Text("Trying to load PHOTO")
                            .foregroundColor(.green)
                            .font(.title)
                        
                        // Try multiple approaches
                        if let image = UIImage(contentsOfFile: mediaURL.path) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .border(Color.green, width: 2)
                        } else {
                            Text("UIImage(contentsOfFile:) FAILED")
                                .foregroundColor(.red)
                        }

                    case .video:
                        Text("Trying to load VIDEO")
                            .foregroundColor(.blue)
                            .font(.title)
                        
                        VideoPlayer(player: AVPlayer(url: mediaURL))
                            .frame(height: 200)
                            .border(Color.blue, width: 2)

                    default:
                        Text("UNKNOWN TYPE: \(String(describing: type))")
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            loadDebugInfo()
        }
    }
    
    private func loadDebugInfo() {
        DispatchQueue.global().async {
            var info = ""
            
            // Check URL
            info += "URL: \(mediaURL.absoluteString)\n"
            info += "Path: \(mediaURL.path)\n"
            
            // Check file existence
            let fileExists = FileManager.default.fileExists(atPath: mediaURL.path)
            info += "File exists: \(fileExists)\n"
            
            if fileExists {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: mediaURL.path)
                    if let size = attributes[.size] as? Int64 {
                        info += "File size: \(size) bytes\n"
                    }
                } catch {
                    info += "Error getting file attributes: \(error)\n"
                }
                
                // Try to read data
                do {
                    let data = try Data(contentsOf: mediaURL)
                    info += "Data loaded: \(data.count) bytes\n"
                    
                    // For images, try to create UIImage
                    if type == .photo {
                        if UIImage(data: data) != nil {
                            info += "UIImage created successfully\n"
                        } else {
                            info += "UIImage creation FAILED\n"
                        }
                    }
                } catch {
                    info += "Error loading data: \(error)\n"
                }
            }
            
            DispatchQueue.main.async {
                self.debugInfo = info
            }
        }
    }
}
