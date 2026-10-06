import SwiftUI

/// 系统设置页面
public struct SettingsView: View {
    @AppStorage("kiki_voice_speed") private var voiceSpeed: Double = 1.0
    @AppStorage("kiki_sound_effects") private var soundEffectsEnabled: Bool = true
    @AppStorage("kiki_speech_volume") private var speechVolume: Double = 1.0
    @AppStorage("selected_language") private var selectedLanguage = "zh"

    @State private var showClearCacheAlert = false
    @State private var cacheCleared = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("声音与发音") {
                    Toggle("音效反馈", isOn: $soundEffectsEnabled)
                        .tint(.orange)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("发音语速")
                            Spacer()
                            Text(String(format: "%.1fx", voiceSpeed))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $voiceSpeed, in: 0.5...1.5, step: 0.1)
                            .tint(.orange)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("发音音量")
                            Spacer()
                            Text(String(format: "%.0f%%", speechVolume * 100))
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $speechVolume, in: 0.0...1.0, step: 0.05)
                            .tint(.orange)
                    }
                }

                Section("语言") {
                    Picker("应用语言", selection: $selectedLanguage) {
                        Text("简体中文").tag("zh")
                        Text("English").tag("en")
                    }
                }

                Section("数据与缓存") {
                    Button {
                        showClearCacheAlert = true
                    } label: {
                        HStack {
                            Text("清理本地缓存")
                                .foregroundColor(.primary)
                            Spacer()
                            if cacheCleared {
                                Text("已清理")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                Section("关于 Kiki") {
                    HStack {
                        Text("当前版本")
                        Spacer()
                        Text("v\(APIConfiguration.shared.appVersion)")
                            .foregroundColor(.secondary)
                    }

                    NavigationLink("用户服务协议") { LegalDocumentView(title: "用户服务协议", resource: "user_agreement") }
                    NavigationLink("儿童隐私保护政策") { LegalDocumentView(title: "儿童隐私保护政策", resource: "privacy_policy") }
                }
            }
            .navigationTitle("系统设置")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
            }
            .alert("清理缓存", isPresented: $showClearCacheAlert) {
                Button("确定", role: .destructive) {
                    URLCache.shared.removeAllCachedResponses()
                    cacheCleared = true
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("确定要清除离线图片和音频缓存吗？")
            }
        }
    }
}


private struct LegalDocumentView: View {
    let title: String
    let resource: String
    var body: some View {
        Group {
            if let url = KikiResources.resourceURL(named: resource, extension: "html", subdirectory: "legal"),
               let html = try? String(contentsOf: url, encoding: .utf8) {
                ScrollView { Text(html.strippingHTML).frame(maxWidth: .infinity, alignment: .leading).padding() }
            } else {
                Text("协议文档暂不可用").foregroundStyle(.secondary)
            }
        }
        .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
    }
}

private extension String {
    var strippingHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
