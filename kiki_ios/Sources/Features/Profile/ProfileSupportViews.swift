import SwiftUI

public struct MyInfoView: View {
    @ObservedObject private var auth = AuthViewModel.shared
    @State private var nickname = ""
    @State private var editing = false
    public init() {}
    public var body: some View {
        NavigationStack {
            List {
                LabeledContent("用户 ID", value: auth.currentUser?.id ?? "—")
                LabeledContent("手机号", value: auth.currentUser?.phone ?? "—")
                LabeledContent("邮箱", value: auth.currentUser?.email?.isEmpty == false ? auth.currentUser!.email! : "—")
                LabeledContent("注册时间", value: auth.currentUser?.createdAt ?? "—")
                LabeledContent("最近登录", value: auth.currentUser?.lastLoginAt ?? "—")
                LabeledContent("昵称", value: auth.currentUser?.nickname.isEmpty == false ? auth.currentUser!.nickname : "未设置")
                    .contentShape(Rectangle()).onTapGesture { nickname = auth.currentUser?.nickname ?? ""; editing = true }
                LabeledContent("VIP 状态", value: auth.currentUser?.isVipActive == true ? "已开通" : "未开通")
            }.navigationTitle("我的资料").navigationBarTitleDisplayMode(.inline)
                .alert("修改昵称", isPresented: $editing) {
                    TextField("昵称", text: $nickname)
                    Button("取消", role: .cancel) {}
                    Button("保存") { Task { await updateNickname() } }
                }
        }
    }
    private func updateNickname() async {
        struct Body: Encodable {
            let name: String
            enum CodingKeys: String, CodingKey { case name }
        }
        do {
            let user: User = try await APIClient.shared.request(endpoint: .updateUserProfile, body: Body(name: nickname))
            if let token = TokenManager.shared.savedToken { TokenManager.shared.save(token: token, user: user) }
            AuthViewModel.shared.refreshCachedUser()
        } catch { }
    }
}

public struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var type = "general"
    @State private var content = ""
    @State private var contact = ""
    @State private var submitting = false
    @State private var message: String?
    public init() {}
    public var body: some View {
        NavigationStack {
            Form {
                Picker("反馈类型", selection: $type) {
                    Text("一般建议").tag("general"); Text("问题反馈").tag("bug"); Text("内容建议").tag("content"); Text("账户问题").tag("account")
                }
                Section("反馈内容（至少 2 个字）") { TextEditor(text: $content).frame(minHeight: 140) }
                Section("联系方式（选填）") { TextField("手机号或邮箱", text: $contact) }
                Button { Task { await submit() } } label: {
                    if submitting { ProgressView() } else { Text("提交反馈").frame(maxWidth: .infinity) }
                }.disabled(submitting || content.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
            }
            .navigationTitle("帮助与反馈").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } } }
            .alert("反馈", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) { Button("好") { if message == "提交成功" { dismiss() } } } message: { Text(message ?? "") }
        }
    }
    private func submit() async {
        struct Body: Encodable { let feedbackType: String; let content: String; let contact: String; let page: String
            enum CodingKeys: String, CodingKey { case feedbackType = "feedback_type", content, contact, page }
        }
        submitting = true
        do {
            let _: EmptyData = try await APIClient.shared.request(endpoint: .feedback, body: Body(feedbackType: type, content: content.trimmingCharacters(in: .whitespacesAndNewlines), contact: contact, page: "profile/help_feedback"))
            message = "提交成功"
        } catch { message = "提交失败：\(error.localizedDescription)" }
        submitting = false
    }
}

public struct AboutView: View {
    public init() {}
    public var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image("kiki_welcome", bundle: KikiResources.bundle).resizable().scaledToFit().frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 20))
                Text("Hi Kiki").font(.title2.bold())
                Text("版本 \(APIConfiguration.shared.appVersion)").foregroundStyle(.secondary)
                Text("通过场景探索与互动点读，陪伴孩子认识生活中的词语。").multilineTextAlignment(.center).padding(.horizontal)
                Link("联系开发者：qishoudong@163.com", destination: URL(string: "mailto:qishoudong@163.com")!)
                Spacer()
            }.padding(.top, 40).navigationTitle("关于我们").navigationBarTitleDisplayMode(.inline)
        }
    }
}
