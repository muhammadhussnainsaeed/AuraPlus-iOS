import SwiftUI

struct MessageInputView: View {
    @State private var text = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) { // Adjusted alignment and spacing
            imagePickerButton()
            messsageTextField()
            audioRecoderButton()
            sendButton()
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background(Color.white)
    }
    
    private func messsageTextField() -> some View {
        TextField("Type a message...", text: $text, axis: .vertical)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.thinMaterial)
            )
    }
    
    private func imagePickerButton() -> some View {
        Button {
            // Action for image picker button
        } label: {
            Image(systemName: "plus")
//                .font(.system(size: 20))
//                .imageScale(.medium)
//                .padding(8)
                .fontWeight(.bold)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
    
    private func sendButton() -> some View {
        Button {
            // Action for send button
        } label: {
            Image(systemName: "arrow.up")
                .fontWeight(.bold)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
    
    private func audioRecoderButton() -> some View {
        Button {
            // Action for audio recorder button
        } label: {
            Image(systemName: "microphone.fill")
                .fontWeight(.bold)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
}

#Preview {
    MessageInputView()
}
