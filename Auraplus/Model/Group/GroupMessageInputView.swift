import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

struct GroupMessageInputView: View {
    @State private var text = ""
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    @State private var isRecording = false
    @State private var showPicker = false
    @State private var selectedMediaURL: URL?
    @State private var pickerMediaType: UTType? = nil

    let groupId: Int
    let senderId: Int
    let senderUsername: String?
    @ObservedObject var webSocketManagerG: WebSocketManagerG

    var body: some View {
        HStack(spacing: 8) {
            imagePickerButton()
            messsageTextField()
            audioRecorderButton()
            sendButton()
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background(ignoresSafeAreaEdges: .bottom)
    }

    private func messsageTextField() -> some View {
        TextField("Type a message...", text: $text, axis: .vertical)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.thinMaterial)
            )
    }

    private func imagePickerButton() -> some View {
        Button {
            showPicker = true
        } label: {
            Image(systemName: "plus")
                .fontWeight(.bold)
                .imageScale(.large)
                .padding(4)
        }
        .sheet(isPresented: $showPicker) {
            PHPicker(mediaURL: $selectedMediaURL, mediaType: $pickerMediaType) { url, type in
                guard let url = url, let type = type else { return }

                if type.conforms(to: .movie) {
                    convertVideoToMP4(originalURL: url) { convertedURL in
                        guard let finalURL = convertedURL else {
                            print("❌ Video conversion failed")
                            return
                        }
                        upload(mediaURL: finalURL, type: "video")
                    }
                } else if type.conforms(to: .image) {
                    convertImageToJPEG(originalURL: url) { jpegURL in
                        guard let finalURL = jpegURL else {
                            print("❌ Image conversion failed")
                            return
                        }
                        upload(mediaURL: finalURL, type: "photo")
                    }
                } else {
                    print("❌ Unsupported media type")
                }
            }
        }
    }

    private func upload(mediaURL: URL, type: String) {
        NetworkService.shared.uploadMedia(username: senderUsername ?? "Anonymous", fileURL: mediaURL) { result in
            switch result {
            case .success(let mediaPath):
                DispatchQueue.main.async {
                    webSocketManagerG.sendMessage(
                        groupId: groupId,
                        senderId: senderId,
                        content: "",
                        mediaURL: mediaPath,
                        messageType: type
                    )
                }
            case .failure(let error):
                print("❌ Upload failed: \(error.localizedDescription)")
            }
        }
    }

    private func sendButton() -> some View {
        Button {
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            webSocketManagerG.sendMessage(groupId: groupId, senderId: senderId, content: text)
            text = ""
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .imageScale(.large)
                .padding(4)
        }
    }

    private func audioRecorderButton() -> some View {
        let longPress = LongPressGesture(minimumDuration: 0.2)
            .onChanged { _ in if !isRecording { startRecording() } }
            .onEnded { _ in stopRecordingAndSend() }

        return Button(action: {}) {
            Image(systemName: isRecording ? "mic.circle.fill" : "mic.circle.fill")
                .font(.system(size: isRecording ? 30 : 28, weight: .bold))
                .foregroundColor(isRecording ? .red : .blue)
                .scaleEffect(isRecording ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
        }
        .simultaneousGesture(longPress)
    }

    private func startRecording() {
        AVAudioApplication.requestRecordPermission { granted in
            guard granted else {
                print("❌ Microphone access denied")
                return
            }

            DispatchQueue.main.async {
                configureAudioSession()

                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                let filename = UUID().uuidString + ".m4a"
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                recordingURL = url

                do {
                    let recorder = try AVAudioRecorder(url: url, settings: settings)
                    recorder.prepareToRecord()
                    recorder.record()
                    audioRecorder = recorder
                    isRecording = true
                    print("🎙️ Recording started")
                } catch {
                    print("❌ Failed to start recording: \(error.localizedDescription)")
                }
            }
        }
    }

    private func stopRecordingAndSend() {
        audioRecorder?.stop()
        isRecording = false
        print("✅ Recording stopped")

        guard let audioURL = recordingURL else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let duration = getAudioDuration(from: audioURL), duration > 0.5 else {
                print("❌ Invalid or too short recording")
                return
            }

            do {
                let fileSize = try FileManager.default.attributesOfItem(atPath: audioURL.path)[.size] as? Int64 ?? 0
                guard fileSize > 1000 else {
                    print("❌ File too small")
                    return
                }
            } catch {
                print("❌ Failed to inspect file: \(error)")
                return
            }

            NetworkService.shared.uploadMedia(username: senderUsername ?? "Anonymous", fileURL: audioURL) { result in
                switch result {
                case .success(let mediaPath):
                    DispatchQueue.main.async {
                        webSocketManagerG.sendMessage(
                            groupId: groupId,
                            senderId: senderId,
                            content: "",
                            mediaURL: mediaPath,
                            messageType: "audio"
                        )
                    }
                case .failure(let error):
                    print("❌ Upload failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func getAudioDuration(from url: URL) -> Double? {
        let asset = AVURLAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("❌ Audio session error: \(error.localizedDescription)")
        }
    }

    private func convertImageToJPEG(originalURL: URL, completion: @escaping (URL?) -> Void) {
        guard let imageData = try? Data(contentsOf: originalURL),
              let image = UIImage(data: imageData),
              let jpegData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try jpegData.write(to: outputURL)
            completion(outputURL)
        } catch {
            print("❌ Failed to save JPG: \(error)")
            completion(nil)
        }
    }

    private func convertVideoToMP4(originalURL: URL, completion: @escaping (URL?) -> Void) {
        let asset = AVAsset(url: originalURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(nil)
            return
        }

        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                if exportSession.status == .completed {
                    completion(outputURL)
                } else {
                    print("❌ Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")")
                    completion(nil)
                }
            }
        }
    }
}
