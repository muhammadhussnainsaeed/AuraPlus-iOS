import SwiftUI

struct LaunchScreen: View {
    @State private var logoOpacity = 0.0
    @State private var scaleEffect: CGFloat = 0.4

    var body: some View {
        ZStack {

            Image("Auralogo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .opacity(logoOpacity)
                .scaleEffect(scaleEffect)
                .onAppear {
                    withAnimation(.smooth(duration: 1.8)) {
                        logoOpacity = 1.0
                        scaleEffect = 1.0
                    }
                }
        }
    }
}

#Preview {
    LaunchScreen()
}
