import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct PHPicker: UIViewControllerRepresentable {
    @Binding var mediaURL: URL?
    @Binding var mediaType: UTType?
    var onPicked: (URL?, UTType?) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .any(of: [.images, .videos])
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPicker

        init(_ parent: PHPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let result = results.first,
                  let type = result.itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(type)
            else {
                parent.onPicked(nil, nil)
                return
            }

            let provider = result.itemProvider

            provider.loadFileRepresentation(forTypeIdentifier: type) { url, _ in
                guard let originalURL = url else {
                    self.parent.onPicked(nil, nil)
                    return
                }

                // Move to temp directory
                let filename = UUID().uuidString + "." + (utType.preferredFilenameExtension ?? "dat")
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

                try? FileManager.default.copyItem(at: originalURL, to: tempURL)
                DispatchQueue.main.async {
                    self.parent.mediaURL = tempURL
                    self.parent.mediaType = utType
                    self.parent.onPicked(tempURL, utType)
                }
            }
        }
    }
}
