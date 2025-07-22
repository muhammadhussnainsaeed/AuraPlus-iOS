import SwiftUI
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .onAppear {
                        downloadAndGenerateThumbnail(from: videoURL)
                    }
            }
        }
    }

    private func downloadAndGenerateThumbnail(from remoteURL: URL) {
        URLSession.shared.downloadTask(with: remoteURL) { tempLocalURL, response, error in
            if let error = error {
                print("❌ Download failed: \(error.localizedDescription)")
                return
            }

            guard let tempLocalURL = tempLocalURL else {
                print("❌ No local file URL")
                return
            }

            // Copy to a more stable location
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory
            let destinationURL = tempDir.appendingPathComponent(UUID().uuidString + ".mp4")

            do {
                try fileManager.copyItem(at: tempLocalURL, to: destinationURL)
                generateThumbnail(from: destinationURL)
            } catch {
                print("❌ Failed to copy file: \(error.localizedDescription)")
            }
        }.resume()
    }

    private func generateThumbnail(from localURL: URL) {
        let asset = AVAsset(url: localURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)

                DispatchQueue.main.async {
                    self.thumbnail = uiImage
                }
            } catch {
                print("❌ Failed to generate thumbnail: \(error.localizedDescription)")
            }
        }
    }
}
