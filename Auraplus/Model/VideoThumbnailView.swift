import AVFoundation
import UIKit
import SwiftUICore

struct VideoThumbnailView: View {
    let videoURL: URL

    var body: some View {
        if let image = generateThumbnail(for: videoURL) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray
        }
    }

    func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("❌ Error generating thumbnail:", error.localizedDescription)
            return nil
        }
    }
}
