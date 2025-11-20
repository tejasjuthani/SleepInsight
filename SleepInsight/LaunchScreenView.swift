import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.35, blue: 0.87),
                    Color(red: 0.06, green: 0.22, blue: 0.64)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Image("AppIconImage")   // We will add this asset next
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .shadow(radius: 12)
        }
    }
}

#Preview {
    LaunchScreenView()
}
