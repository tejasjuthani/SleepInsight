import SwiftUI

struct LaunchAnimationView: View {
    let onFinish: () -> Void

    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Apple-style clean deep blue gradient
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.35, blue: 0.87),
                    Color(red: 0.06, green: 0.22, blue: 0.64)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .opacity(opacity)
                .scaleEffect(scale)
                .shadow(radius: 10)
        }
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {

        // Apple-style quick clean animation
        withAnimation(.easeInOut(duration: 0.55)) {
            opacity = 0.0
            scale = 0.97     // very subtle, almost unnoticeable
        }

        // Remove splash exactly when animation ends
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            onFinish()
        }
    }
}

#Preview {
    LaunchAnimationView(onFinish: {})
}
