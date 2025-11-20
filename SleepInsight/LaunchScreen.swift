import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .shadow(radius: 10)
        }
    }
}

#Preview {
    LaunchScreen()
}
