import SwiftUI

/// Shared glass confirmation shown before sending a user to the VIP purchase page.
struct VipUnlockDialog: View {
    let onDismiss: () -> Void
    let onSubscribe: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.24)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 1, green: 0.82, blue: 0.27), Color(red: 0.91, green: 0.48, blue: 0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.66), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 1))
                    .shadow(color: Color.orange.opacity(0.2), radius: 10, y: 4)

                VStack(spacing: 7) {
                    Text("解锁 VIP 内容")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.25, green: 0.20, blue: 0.15))
                    Text("该内容为会员专享。前往开通 Kiki VIP 后，即可继续学习。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.38, green: 0.34, blue: 0.29))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 10) {
                    Button(action: onDismiss) {
                        Text("暂不")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(red: 0.38, green: 0.34, blue: 0.29))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(.white.opacity(0.48), in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Button(action: onSubscribe) {
                        HStack(spacing: 6) {
                            Text("去开通")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(LinearGradient(
                            colors: [Color(red: 1, green: 0.71, blue: 0.13), Color(red: 0.91, green: 0.43, blue: 0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))
                        .shadow(color: Color.orange.opacity(0.24), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .frame(maxWidth: 340)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.36), .white.opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.82), lineWidth: 1.2)
            }
            .shadow(color: .black.opacity(0.17), radius: 28, y: 13)
            .padding(.horizontal, 28)
            .transition(.scale(scale: 0.94).combined(with: .opacity))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .accessibilityAddTraits(.isModal)
    }
}
