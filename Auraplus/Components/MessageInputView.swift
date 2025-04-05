import SwiftUI

struct MessageInputView: View {
    @State private var text = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) { // Adjusted alignment and spacing
            imagePickerButton()
            messsageTextField()
            audioRecoderButton()
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
            // Action for image picker button
        } label: {
            Image(systemName: "plus")
                .fontWeight(.bold)
                .imageScale(.large)
                .padding(4)
        }
    }
    
    private func sendButton() -> some View {
        Button {
            // Action for send button
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .imageScale(.large)
                .padding(4)
        }
    }
    
    private func audioRecoderButton() -> some View {
        Button {
            // Action for audio recorder button
        } label: {
            Image(systemName: "microphone.fill")
                .fontWeight(.bold)
                .imageScale(.large)
                .padding(7)
        }
    }
}

#Preview {
    MessageInputView()
}
