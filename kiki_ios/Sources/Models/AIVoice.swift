import Foundation

/// AI 伴学助手动作指令
public struct AiVoiceAction: Codable, Identifiable, Hashable {
    public var id: String { actionId }
    public let actionId: String
    public let sequence: Int
    public let type: String
    public let targetItemId: String?
    public let text: String
    public let audioUrl: String?

    enum CodingKeys: String, CodingKey {
        case actionId = "action_id"
        case sequence
        case type
        case targetItemId = "target_item_id"
        case text
        case audioUrl = "audio_url"
    }

    public init(
        actionId: String,
        sequence: Int = 0,
        type: String = "speak",
        targetItemId: String? = nil,
        text: String,
        audioUrl: String? = nil
    ) {
        self.actionId = actionId
        self.sequence = sequence
        self.type = type
        self.targetItemId = targetItemId
        self.text = text
        self.audioUrl = audioUrl
    }
}

/// AI 伴学助手推荐与欢迎语
public struct AiVoiceRecommendation: Codable {
    public let enabled: Bool
    public let reason: String
    public let greetingText: String
    public let greetingAudioUrl: String?
    public let mode: String

    enum CodingKeys: String, CodingKey {
        case enabled
        case reason
        case greetingText = "greeting_text"
        case greetingAudioUrl = "greeting_audio_url"
        case mode
    }

    public init(
        enabled: Bool = true,
        reason: String = "",
        greetingText: String = "嗨！我是 Kiki，我们一起来探索这个好玩的场景吧！",
        greetingAudioUrl: String? = nil,
        mode: String = "interactive"
    ) {
        self.enabled = enabled
        self.reason = reason
        self.greetingText = greetingText
        self.greetingAudioUrl = greetingAudioUrl
        self.mode = mode
    }
}

/// AI 伴学会话结构
public struct AiVoiceSession: Codable {
    public let sessionId: String
    public let sceneId: String
    public let status: String
    public let action: AiVoiceAction?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case sceneId = "scene_id"
        case status
        case action
    }
}
