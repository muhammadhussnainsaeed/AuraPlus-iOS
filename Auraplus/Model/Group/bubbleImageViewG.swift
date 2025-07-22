import SwiftUI
import AVKit

struct bubbleImageViewG: View {
    let item: GroupMessageItem
    var onDelete: (() -> Void)? = nil

    @State private var showViewer = false
    @State private var localURL: URL?
    @State private var selectedType: MessageType = .text

    var body: some View {
        HStack {
            if item.direction == .sent { Spacer() }

            contentWithOptionalSenderName()

            if item.direction == .received { Spacer() }
        }
        .fullScreenCover(isPresented: $showViewer) {
            if let url = localURL {
                MediaViewerView(mediaURL: url, type: selectedType)
            }
        }
    }

    private func contentWithOptionalSenderName() -> some View {
        VStack(alignment: item.horizantalAlignment, spacing: 4) {
            if item.direction == .received {
                Text(item.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.leading, 5)
            }

            messageContentView()
        }
    }

    private func messageContentView() -> some View {
        VStack(spacing: 2) {
            if let fileName = item.media_url,
               let remoteURL = URL(string: "http://192.168.100.8:8888/get-media/?link=\(fileName)") {

                let mediaView: AnyView = {
                    switch item.type {
                    case .photo:
                        return AnyView(
                            AsyncImage(url: remoteURL) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
                                @unknown default: EmptyView()
                                }
                            }
                            .frame(width: 220, height: 180)
                            .clipped()
                        )

                    case .video:
                        return AnyView(
                            ZStack {
                                VideoThumbnailView(videoURL: remoteURL)
                                    .frame(width: 220, height: 180)
                                    .clipped()

                                Image(systemName: "play.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .onTapGesture {
                                downloadAndOpen(remoteURL: remoteURL, type: .video)
                            }
                        )

                    default:
                        return AnyView(EmptyView())
                    }
                }()

                VStack(spacing: 2) {
                    mediaView
                }
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary))
                .padding(6)
                .contentShape(Rectangle()) // ✅ Make the whole bubble tappable
                .onLongPressGesture {
                    onDelete?()
                }

                timeStampView()
            }
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
