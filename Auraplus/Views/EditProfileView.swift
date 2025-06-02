//
//  EditProfileView.swift
//  Auraplus
//
//  Created by Hussnain on 23/3/25.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var session: SessionManager
    @State private var selectedImage: UIImage?
    @State private var base64Image: String?
    @State private var showImagePicker = false
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else if let imageData = session.currentUser?.profileImageData,
                                      let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50)
                            }

                            Text("Edit your name and add an optional profile picture")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .padding(.leading, 8)
                        }

                        Button("Edit") {
                            showImagePicker = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.leading, 15)

                        InputView(text: $name, title: "", placeholder: "Enter your name")
                            .padding(.top, -8)
                    }

                    Button("Confirm") {
                        uploadProfile()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    .fontWeight(.medium)
                    .font(.callout)
                    .foregroundColor(.blue)
                    .padding(5)
                }
            }
        }
        .onAppear {
            if let currentUser = session.currentUser {
                AuthService.shared.getUserPhotoandName(username: currentUser.username) { image, fetchedName in
                    DispatchQueue.main.async {
                        if let image = image {
                            let imageData = image.jpegData(compressionQuality: 1.0)
                            session.currentUser?.profileImageData = imageData
                            selectedImage = image
                            print("✅ Profile photo updated from server")
                        } else {
                            print("❌ Failed to fetch user photo")
                        }

                        if let fetchedName = fetchedName {
                            name = fetchedName
                            session.currentUser?.name = fetchedName
                            print("✅ Name updated from server: \(fetchedName)")
                        }
                    }
                }
            } else {
                print("❌ No current user in session")
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                if let cropped = cropAndResize(image: image) {
                    selectedImage = cropped
                    base64Image = compressAndConvertToBase64(cropped)
                }
            }
        }
    }

    // MARK: Upload Function
    func uploadProfile() {
        let imageToSend = base64Image ?? session.currentUser?.profileImageData?.base64EncodedString()
        guard let base64 = imageToSend else {
            print("⚠️ No image data to upload.")
            return
        }

        AuthService.shared.updateUserPhoto(name: name, username: session.currentUser?.username ?? "", imageBase64: base64) { result in
            switch result {
            case .success(let msg): print("✅", msg)
            case .failure(let error): print("❌", error.localizedDescription)
            }
        }
    }

    // MARK: Image Processing
    func cropAndResize(image: UIImage) -> UIImage? {
        let size = CGSize(width: 500, height: 500)
        let cropSize = min(image.size.width, image.size.height)
        let cropRect = CGRect(x: (image.size.width - cropSize) / 2,
                              y: (image.size.height - cropSize) / 2,
                              width: cropSize,
                              height: cropSize)

        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return nil }
        let cropped = UIImage(cgImage: cgImage)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        cropped.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized
    }

    func compressAndConvertToBase64(_ image: UIImage) -> String? {
        var quality: CGFloat = 0.9
        var data = image.jpegData(compressionQuality: quality)

        while let d = data, d.count > 500_000, quality > 0.01 {
            quality -= 0.05
            data = image.jpegData(compressionQuality: quality)
        }

        return data?.base64EncodedString()
    }
}

// MARK: - Preview
#Preview {
    EditProfileView()
        .environmentObject(SessionManager.shared)
}
