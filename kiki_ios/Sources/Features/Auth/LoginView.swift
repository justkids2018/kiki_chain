import SwiftUI
import WebKit

/// Native SwiftUI recreation of kiki_web's shared landscape login/register page.
public struct LoginView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared

    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isRegister = false
    @State private var agreeTerms = false
    @State private var agreement: AgreementDocument?
    @State private var keyboardInset: CGFloat = 0

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let compactHeight = geometry.size.height < 430
            let cardHeight = compactHeight ? 376.0 : 430.0

            ZStack {
                LinearGradient(colors: [Color(hex: 0xFFF8EFDC), Color(hex: 0xFFF5E7CF)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                RoundedRectangle(cornerRadius: 36)
                    .fill(.white.opacity(0.10))
                    .overlay {
                        GeometryReader { proxy in
                            ZStack(alignment: .bottomLeading) {
                                Circle().fill(Color(hex: 0x75FFD678)).frame(width: 74, height: 74).offset(x: 86, y: -proxy.size.height + 110)
                                CrystalStar(earned: true, size: 28)
                                    .rotationEffect(.degrees(9)).offset(x: proxy.size.width - 170, y: -proxy.size.height + 68)
                                CrystalStar(earned: true, size: 15)
                                    .rotationEffect(.degrees(-14)).offset(x: 250, y: -proxy.size.height + 90)

                                croppedMascot("kiki_map", visibleHeight: compactHeight ? 128 : 170, originalHeight: 1536, transparentTop: 121, transparentBottom: 253)
                                    .offset(x: compactHeight ? 44 : 98, y: compactHeight ? 44 : 47)
                                croppedMascot("yuki_map", visibleHeight: compactHeight ? 134 : 178, originalHeight: 1536, transparentTop: 137, transparentBottom: 243)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .offset(x: compactHeight ? -22 : -78, y: compactHeight ? 42 : 45)
                                croppedMascot("mimi_map", visibleHeight: compactHeight ? 62 : 82, originalHeight: 1312, transparentTop: 138, transparentBottom: 234)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .offset(x: compactHeight ? -144 : -238, y: compactHeight ? 32 : 31)

                                KikiResources.image(named: "meadow_wide")?
                                    .resizable().scaledToFill()
                                    .frame(width: proxy.size.width + 60, height: compactHeight ? 112 : 150)
                                    .clipped()
                                    .offset(x: -30, y: 24)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 36))
                    .frame(maxWidth: 1040)
                    .padding(.horizontal, geometry.size.width < 860 ? 22 : 34)

                VStack {
                    Spacer(minLength: 0)
                    authCard(compactHeight: compactHeight)
                        .frame(maxWidth: 390)
                        .frame(height: cardHeight)
                        .offset(y: cardLift(for: geometry.size.height))
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 1040)
                .padding(.horizontal, geometry.size.width < 860 ? 22 : 34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(item: $agreement) { document in
                AgreementSheet(document: document)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                keyboardInset = max(0, UIScreen.main.bounds.maxY - frame.minY)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardInset = 0
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func cardLift(for height: CGFloat) -> CGFloat {
        guard keyboardInset > 0 else { return 0 }
        let compact = height < 430
        return -(keyboardInset * 0.62).clamped(to: compact ? 76...132 : 112...190)
    }

    private func croppedMascot(_ name: String, visibleHeight: CGFloat, originalHeight: CGFloat, transparentTop: CGFloat, transparentBottom: CGFloat) -> some View {
        let visibleSourceHeight = originalHeight - transparentTop - transparentBottom
        let fullHeight = visibleHeight * originalHeight / visibleSourceHeight
        let topOffset = fullHeight * transparentTop / originalHeight

        return Group {
            if let image = KikiResources.image(named: name) {
                image.resizable().scaledToFit().frame(height: fullHeight).offset(y: -topOffset)
            }
        }
        .frame(height: visibleHeight, alignment: .top)
        .clipped()
    }

    private func authCard(compactHeight: Bool) -> some View {
        let verticalPadding: CGFloat = compactHeight ? 14 : 20
        return VStack(spacing: compactHeight ? 8 : 10) {
            modeTabs
            Group {
                if isRegister {
                    VStack(spacing: compactHeight ? 10 : 12) {
                        phoneField
                        passwordField
                        confirmPasswordField
                    }
                    .transition(.opacity)
                } else {
                    VStack(spacing: compactHeight ? 10 : 14) {
                        phoneField
                        passwordField
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)

            if let error = authViewModel.errorMessage, !error.isEmpty {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0xFFEC5B57))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            termsRow

            Button(action: submit) {
                HStack(spacing: 8) {
                    if authViewModel.isLoading { ProgressView().tint(.white) }
                    Text(isRegister ? "注册" : "登录")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: compactHeight ? 46 : 48)
                .background(LinearGradient(colors: [Color(hex: 0xFFA4D564), Color(hex: 0xFF79BF3F)], startPoint: .top, endPoint: .bottom), in: Capsule())
                .shadow(color: Color(hex: 0x2A5A9B2B), radius: 16, y: 6)
            }
            .buttonStyle(.plain)
            .disabled(authViewModel.isLoading)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, verticalPadding)
        .background(Color(hex: 0xFFFFF9EC))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.9), lineWidth: 1.4))
        .shadow(color: Color(hex: 0x235D4A2E), radius: 30, y: 14)
    }

    private var modeTabs: some View {
        HStack(spacing: 0) {
            modeButton("登录", selected: !isRegister) { withAnimation(.easeOut(duration: 0.16)) { isRegister = false; authViewModel.errorMessage = nil } }
            modeButton("注册", selected: isRegister) { withAnimation(.easeOut(duration: 0.16)) { isRegister = true; authViewModel.errorMessage = nil } }
        }
        .padding(4)
        .frame(height: 42)
        .background(Color(hex: 0xFFF2E6D0), in: Capsule())
    }

    private func modeButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: selected ? .bold : .medium))
                .foregroundStyle(Color(hex: selected ? 0xFF3F2718 : 0xFF7A6A5B))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    if selected {
                        Capsule().fill(.white).shadow(color: Color(hex: 0x165D4A2E), radius: 10, y: 3)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var phoneField: some View {
        authField(icon: "phone", placeholder: "请输入手机号", text: $phone, keyboard: .phonePad)
    }

    private var passwordField: some View {
        authField(icon: "lock", placeholder: "请输入密码", text: $password, secure: true)
    }

    private var confirmPasswordField: some View {
        authField(icon: "lock", placeholder: "请确认密码", text: $confirmPassword, secure: true)
    }

    private func authField(icon: String, placeholder: String, text: Binding<String>, secure: Bool = false, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon == "phone" ? "phone" : "lock")
                .font(.system(size: 19))
                .foregroundStyle(Color(hex: 0xFFB7AB9D))
                .frame(width: 22)
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .textContentType(.telephoneNumber)
                }
            }
            .font(.system(size: 16))
            .foregroundStyle(Color(hex: 0xFF3F2718))
            .tint(Color(hex: 0xFF79BF3F))
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: 0xFFE7DCCB), lineWidth: 1))
    }

    private var termsRow: some View {
        HStack(spacing: 4) {
            Button { agreeTerms.toggle() } label: {
                Image(systemName: agreeTerms ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 17))
                    .foregroundStyle(agreeTerms ? Color(hex: 0xFF79BF3F) : Color(hex: 0xFFB7AB9D))
            }
            .buttonStyle(.plain)
            Text("我已阅读并同意")
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: 0xFF7A6A5B))
            Button("《用户协议》") { agreement = .user }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: 0xFF66A932))
            Text("和").font(.system(size: 12)).foregroundStyle(Color(hex: 0xFF7A6A5B))
            Button("《隐私政策》") { agreement = .privacy }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color(hex: 0xFF66A932))
            Spacer(minLength: 0)
        }
    }

    private var canSubmit: Bool {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneValid = trimmedPhone.range(of: "^1[3-9][0-9]{9}$", options: .regularExpression) != nil
        let passwordValid = (6...20).contains(password.count)
            && password.range(of: "[A-Za-z]", options: .regularExpression) != nil
            && password.range(of: "[0-9]", options: .regularExpression) != nil
        return phoneValid && passwordValid && (!isRegister || password == confirmPassword)
    }

    private func submit() {
        guard canSubmit else {
            if phone.range(of: "^1[3-9][0-9]{9}$", options: .regularExpression) == nil { authViewModel.errorMessage = "请输入有效的手机号。" }
            else if !(6...20).contains(password.count) { authViewModel.errorMessage = "密码长度应为 6–20 位。" }
            else if password.range(of: "[A-Za-z]", options: .regularExpression) == nil || password.range(of: "[0-9]", options: .regularExpression) == nil { authViewModel.errorMessage = "密码须同时包含字母和数字。" }
            else if isRegister && password != confirmPassword { authViewModel.errorMessage = "两次输入的密码不一致。" }
            return
        }
        Task {
            if isRegister {
                _ = await authViewModel.register(phone: phone.trimmingCharacters(in: .whitespacesAndNewlines), password: password, nickname: "")
            } else {
                _ = await authViewModel.login(phone: phone.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            }
        }
    }
}

private struct AgreementDocument: Identifiable {
    enum Kind: Equatable { case user, privacy }
    let kind: Kind
    var id: Int { kind == .user ? 0 : 1 }
    var title: String { kind == .user ? "用户协议" : "隐私政策" }
    var resource: String { kind == .user ? "user_agreement" : "privacy_policy" }
    static let user = AgreementDocument(kind: .user)
    static let privacy = AgreementDocument(kind: .privacy)
}

private struct AgreementSheet: View {
    let document: AgreementDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AgreementHTMLView(name: document.resource)
                .navigationTitle(document.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
        }
    }
}

private struct AgreementHTMLView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        if let url = KikiResources.resourceURL(named: name, extension: "html", subdirectory: "legal") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

private extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, opacity: Double((hex >> 24) & 0xFF) / 255)
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
