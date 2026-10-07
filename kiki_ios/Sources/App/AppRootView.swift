import SwiftUI

/// Mirrors the Flutter splash route's auth gate and keeps the primary journey linear.
public struct AppRootView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var splashFinished = false
    @State private var splashOpacity = 0.82

    public init() {}

    public var body: some View {
        Group {
            if !splashFinished {
                ZStack {
                    Color(red: 0.969, green: 0.933, blue: 0.859).ignoresSafeArea()
                    if let welcome = KikiResources.image(named: "kiki_welcome") {
                        welcome
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 720)
                            .padding(.horizontal, 20)
                            .opacity(splashOpacity)
                    }
                }
                .task {
                    withAnimation(.easeOut(duration: 0.18)) { splashOpacity = 1 }
                    try? await Task.sleep(nanoseconds: 700_000_000)
                    withAnimation(.easeInOut(duration: 0.18)) { splashFinished = true }
                }
            } else if authViewModel.isLoggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: splashFinished)
        .animation(.easeInOut(duration: 0.2), value: authViewModel.isLoggedIn)
    }
}
