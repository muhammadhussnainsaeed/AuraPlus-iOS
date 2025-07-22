import SwiftUI
import AVKit
import Combine

struct BubbleAudioViewG: View {
    let item: GroupMessageItem
    var onDelete: (() -> Void)? = nil  // ✅ Delete handler

    @State private var avPlayer: AVPlayer?
    @State private var isPlaying = false
    @State private var sliderValue: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    @State private var isDownloading = false
    @State private var downloadError: String?
    @StateObject private var playerObserver = PlayerObserver()

    var body: some View {
        VStack(alignment: item.horizantalAlignment, spacing: 3) {
            // 👤 Show sender name if received
            if item.direction == .received {
                Text(item.username)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: item.alignment)
                    .padding(.horizontal, 10)
            }

            // 🔊 Audio bubble with long-press gesture
            HStack {
                playButton()

                if isDownloading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(item.foregroundColor)
                } else {
                    Slider(value: $sliderValue, in: 0...duration, onEditingChanged: { editing in
                        if !editing {
                            avPlayer?.seek(to: CMTime(seconds: sliderValue, preferredTimescale: 600))
                        }
                    })
                    .tint(item.foregroundColor)
                    .frame(width: 120)
                }

                Text(formatTime(sliderValue))
                    .font(.caption)
                    .foregroundColor(item.foregroundColor)
            }
            .padding(8)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle()) // 👈 makes whole bubble tappable
            .onLongPressGesture {
                onDelete?()              // ✅ Trigger delete
            }
            .onAppear(perform: setupAudio)

            // 🔴 Show error if any
            if let error = downloadError {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            // 🕓 Timestamp
            Text(item.timestamp)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, item.direction == .received ? 5 : 100)
                .padding(.trailing, item.direction == .received ? 100 : 5)
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.direction == .received ? 5 : 100)
        .padding(.trailing, item.direction == .received ? 100 : 5)
    }

    @MainActor
    private func setupAudio() {
        guard let mediaPath = item.media_url else {
            downloadError = "No media URL"
            return
        }

        if let localURL = getLocalFileURL(from: mediaPath),
           FileManager.default.fileExists(atPath: localURL.path) {
            createPlayer(with: localURL)
            return
        }

        downloadAudioFile(mediaPath: mediaPath)
    }

    private func getLocalFileURL(from mediaPath: String) -> URL? {
        let filename = URL(fileURLWithPath: mediaPath).lastPathComponent
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDir.appendingPathComponent(filename)
    }

    private func downloadAudioFile(mediaPath: String) {
        isDownloading = true
        downloadError = nil

        NetworkService.shared.downloadMedia(linkPath: mediaPath) { result in
            DispatchQueue.main.async {
                self.isDownloading = false

                switch result {
                case .success(let localURL):
                    self.createPlayer(with: localURL)
                case .failure(let error):
                    self.downloadError = "Download failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func createPlayer(with url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            downloadError = "File not found"
            return
        }

        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
            if fileSize < 1000 {
                downloadError = "File too small - check server response"
                return
            }
        } catch {
            downloadError = "File error: \(error.localizedDescription)"
            return
        }

        configureAudioSession()

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.volume = 1.0

        self.avPlayer = player
        setupPlayerObservers(playerItem: playerItem)

        Task {
            do {
                let assetDuration = try await playerItem.asset.load(.duration)
                let seconds = CMTimeGetSeconds(assetDuration)
                if seconds.isFinite && seconds > 0 {
                    await MainActor.run {
                        self.duration = seconds
                    }
                }
            } catch {
                print("⛔ Failed to load duration: \(error)")
            }
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("⛔ Audio session error: \(error)")
        }
    }

    private func setupPlayerObservers(playerItem: AVPlayerItem) {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.isPlaying = false
                self.sliderValue = 0
                self.stopTimer()
            }
            .store(in: &playerObserver.cancellables)

        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                if status == .failed {
                    self.downloadError = "Playback failed"
                }
            }
            .store(in: &playerObserver.cancellables)
    }

    private func togglePlayback() {
        guard let player = avPlayer else { return }

        if isPlaying {
            player.pause()
            stopTimer()
        } else {
            try? AVAudioSession.sharedInstance().setActive(true)
            player.play()
            startTimer()
        }

        isPlaying.toggle()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let current = avPlayer?.currentTime() {
                self.sliderValue = CMTimeGetSeconds(current)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func playButton() -> some View {
        Button(action: togglePlayback) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(item.foregroundColor)
                .padding(6)
        }
        .disabled(isDownloading || avPlayer == nil)
    }

    private func formatTime(_ value: Double) -> String {
        let minutes = Int(value) / 60
        let seconds = Int(value) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
