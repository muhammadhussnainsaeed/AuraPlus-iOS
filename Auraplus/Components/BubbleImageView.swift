import SwiftUI
import AVKit

struct bubbleImageView: View {
    let item: MessageItem
    var onDelete: (() -> Void)? = nil

    @State private var showViewer = false
    @State private var localURL: URL?
    @State private var selectedType: MessageType = .text

    var body: some View {
        HStack {
            if item.direction == .sent { Spacer() }

            messageContentWithTimestamp()

            if item.direction == .received { Spacer() }
        }
        .fullScreenCover(isPresented: $showViewer) {
            if let url = localURL {
                MediaViewerView(mediaURL: url, type: selectedType)
            }
        }
    }

    @ViewBuilder
    private func messageContentWithTimestamp() -> some View {
        if let fileName = item.media_url,
           let remoteURL = URL(string: "http://192.168.100.8:8888/get-media/?link=\(fileName)") {

            let mediaView = mediaContent(for: remoteURL)

            VStack(spacing: 2) {
                mediaView
                    .background(item.backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary))
                    .padding(6)

                timeStampView()
            }
            .contentShape(Rectangle()) // 👈 makes whole VStack tappable
            .onLongPressGesture {
                onDelete?()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func mediaContent(for url: URL) -> some View {
        switch item.type {
        case .photo:
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    Image(systemName: "xmark.octagon.fill")
                        .foregroundColor(.red)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 220, height: 180)
            .clipped()

        case .video:
            ZStack {
                VideoThumbnailView(videoURL: url)
                    .frame(width: 220, height: 180)
                    .clipped()

                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .onTapGesture {
                downloadAndOpen(remoteURL: url, type: .video)
            }

        default:
            EmptyView()
        }
    }

    private func timeStampView() -> some View {
        HStack {
            Text(item.timestamp)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, item.direction == .received ? 6 : 175)
                .padding(.trailing, item.direction == .received ? 175 : 6)
        }
        .padding(.horizontal, 7)
    }

    private func downloadAndOpen(remoteURL: URL, type: MessageType) {
        let ext = (type == .photo) ? ".jpg" : ".mp4"
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ext)

        URLSession.shared.downloadTask(with: remoteURL) { tempURL, _, error in
            guard let tempURL = tempURL, error == nil else {
                print("❌ Download failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                try FileManager.default.copyItem(at: tempURL, to: destination)
                DispatchQueue.main.async {
                    self.localURL = destination
                    self.selectedType = type
                    self.showViewer = true
                }
            } catch {
                print("❌ Saving failed:", error.localizedDescription)
            }
        }.resume()
    }
}
