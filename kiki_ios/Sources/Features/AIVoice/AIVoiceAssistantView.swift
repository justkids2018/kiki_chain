import SwiftUI

/// AI 伴学助手弹窗界面
public struct AIVoiceAssistantView: View {
    @StateObject private var viewModel = AIVoiceViewModel()
    @StateObject private var recorder = AudioRecorderManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""

    public let sceneId: String?

    public init(sceneId: String? = nil) {
        self.sceneId = sceneId
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Kiki 形象与对话展示区
                ScrollView {
                    VStack(spacing: 16) {
                        // Kiki 形象动画徽章
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "face.smiling.inverse")
                                .font(.system(size: 48))
                                .foregroundColor(.orange)
                        }
                        .padding(.top, 16)

                        // 消息气泡流
                        ForEach(viewModel.messages.indices, id: \.self) { idx in
                            let msg = viewModel.messages[idx]
                            HStack {
                                if !msg.isKiki { Spacer() }

                                Text(msg.text)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(msg.isKiki ? Color(red: 0.96, green: 0.96, blue: 0.98) : Color.orange)
                                    )
                                    .foregroundColor(msg.isKiki ? .primary : .white)

                                if msg.isKiki { Spacer() }
                            }
                        }

                        if viewModel.isThinking {
                            HStack {
                                ProgressView()
                                    .tint(.orange)
                                Text("Kiki 正在思考...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                // 底部语音录音与文字输入区
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("向 Kiki 提问或跟读词语...", text: $inputText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.gray.opacity(0.12)))

                        Button {
                            let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            inputText = ""
                            Task {
                                await viewModel.sendInput(text: text, sceneId: sceneId)
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color.orange))
                        }
                        .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // 按住跟读录音按钮
                    Button {
                        if recorder.isRecording {
                            _ = recorder.stopRecording()
                            Task {
                                await viewModel.sendInput(text: "我读完了，你觉得怎么样？", sceneId: sceneId)
                            }
                        } else {
                            Task {
                                _ = await recorder.startRecording()
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.fill")
                                .font(.title3)
                            Text(recorder.isRecording ? "正在倾听中... (点击结束)" : "点击对 Kiki 说话")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(recorder.isRecording ? .red : .orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(recorder.isRecording ? Color.red : Color.orange, lineWidth: 1.5)
                        )
                    }
                }
                .padding()
                .background(Color.white)
            }
            .navigationTitle("Kiki 伴学助手")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}
