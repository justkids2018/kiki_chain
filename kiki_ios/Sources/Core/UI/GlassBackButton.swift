import SwiftUI

/// Shared dismissal control for full-screen destinations and sheets.
public struct GlassBackButton: View {
    @Environment(\.dismiss) private var dismiss
    private let action: (() -> Void)?

    public init(action: (() -> Void)? = nil) { self.action = action }

    public var body: some View {
        Button { if let action { action() } else { dismiss() } } label: {
            Image(systemName: "chevron.backward")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(red: 0.36, green: 0.38, blue: 0.39))
                .frame(width: 42, height: 42)
                .background(.regularMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 1.2))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("返回")
    }
}

/// A custom header keeps the button outside iOS's automatic toolbar glass.
public struct GlassNavigationHeader: View {
    private let title: LocalizedStringKey

    public init(_ title: LocalizedStringKey) { self.title = title }

    public var body: some View {
        HStack {
            GlassBackButton()
            Spacer()
            Text(title)
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Color.clear.frame(width: 42, height: 42)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .background(Color.clear)
    }
}
