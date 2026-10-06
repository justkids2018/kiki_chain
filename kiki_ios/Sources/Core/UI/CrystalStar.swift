import SwiftUI

/// Shared golden glass star used wherever the app shows a learning reward.
struct CrystalStar: View {
    var earned: Bool
    var size: CGFloat = 20
    var pulsing = false

    var body: some View {
        let symbol = Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)

        ZStack {
            if earned {
                symbol
                    .foregroundStyle(.black.opacity(0.16))
                    .blur(radius: size * 0.08)
                    .offset(y: size * 0.09)
                symbol
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 1, green: 0.98, blue: 0.71),
                                 Color(red: 1, green: 0.79, blue: 0.13),
                                 Color(red: 0.82, green: 0.43, blue: 0.02)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color(red: 1, green: 0.68, blue: 0.08).opacity(0.50), radius: size * 0.20)
                symbol
                    .foregroundStyle(LinearGradient(
                        colors: [.white.opacity(0.88), .white.opacity(0.12), .clear],
                        startPoint: .top, endPoint: .bottom))
                    .scaleEffect(x: 0.76, y: 0.54, anchor: .top)
                    .offset(y: -size * 0.07)
                Image(systemName: "star")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white.opacity(0.72))
                    .shadow(color: .white.opacity(0.9), radius: size * 0.04)
            } else {
                symbol.foregroundStyle(.white.opacity(0.36))
                Image(systemName: "star")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color(red: 0.69, green: 0.57, blue: 0.35).opacity(0.52))
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(pulsing ? 1.24 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(earned ? "已获得星星" : "待获得星星")
    }
}

struct CrystalStarBar: View {
    let earned: Int
    var size: CGFloat = 20
    var pulsingIndex: Int? = nil

    static let spacing: CGFloat = 3
    static let horizontalPadding: CGFloat = 8

    var body: some View {
        HStack(spacing: Self.spacing) {
            ForEach(0..<3, id: \.self) { index in
                CrystalStar(earned: index < earned, size: size, pulsing: pulsingIndex == index)
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.70), lineWidth: 1))
        .shadow(color: Color(red: 0.88, green: 0.61, blue: 0.12).opacity(0.15), radius: 8, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("已获得 \(earned) 颗星，共 3 颗")
    }
}
