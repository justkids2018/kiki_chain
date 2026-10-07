import Foundation
import Combine

import SwiftUI

/// AI 伴学助手 ViewModel
@MainActor
public final class AIVoiceViewModel: ObservableObject {
    @Published public private(set) var greeting: String = "嗨！我是 Kiki，我们一起玩找一找游戏吧！"
    @Published public private(set) var isThinking: Bool = false
    @Published public private(set) var currentActionText: String?
    @Published public private(set) var messages: [(isKiki: Bool, text: String)] = []

    private let apiClient: APIClient
    private let audioPlayer: AudioPlayerManager

    public init(apiClient: APIClient = .shared, audioPlayer: AudioPlayerManager? = nil) {
        self.apiClient = apiClient
        self.audioPlayer = audioPlayer ?? .shared
        self.messages.append((isKiki: true, text: greeting))
    }

    /// 发起语音/文本对话
    public func sendInput(text: String, sceneId: String? = nil) async {
        guard !text.isEmpty else { return }
        messages.append((isKiki: false, text: text))
        isThinking = true

        struct ChatRequest: Encodable {
            let message: String
            let sceneId: String?

            enum CodingKeys: String, CodingKey {
                case message
                case sceneId = "scene_id"
            }
        }

        struct ChatResponse: Decodable {
            let reply: String
            let audioUrl: String?

            enum CodingKeys: String, CodingKey {
                case reply
                case audioUrl = "audio_url"
            }
        }

        do {
            let resp: ChatResponse = try await apiClient.request(
                endpoint: .aiVoiceChat,
                body: ChatRequest(message: text, sceneId: sceneId)
            )
            self.isThinking = false
            self.currentActionText = resp.reply
            self.messages.append((isKiki: true, text: resp.reply))

            if let audioUrlStr = resp.audioUrl, let url = URL(string: audioUrlStr) {
                audioPlayer.play(url: url)
            }
        } catch {
            // 智能本地兜底应答，保证儿童互动不冷场
            self.isThinking = false
            let fallbackReplies = [
                "太棒了！你读得真准，找到了新词条！",
                "试着找找画面里闪闪发光的东西吧！",
                "真聪明！继续点击下一个热区看看有什么秘密！"
            ]
            let reply = fallbackReplies.randomElement()!
            self.currentActionText = reply
            self.messages.append((isKiki: true, text: reply))
        }
    }
}
