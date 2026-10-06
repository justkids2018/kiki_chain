import Foundation

/// 场景内交互热区项模型（点读词条）
public struct SceneItem: Codable, Identifiable, Hashable {
    public let id: String
    public let sceneId: String
    public let itemIndex: Int?
    public let text: String
    public let textPinyin: String?
    public let textEnglish: String?
    public let audioUrl: String?
    public let coordinates: Coordinates?

    enum CodingKeys: String, CodingKey {
        case id
        case sceneId = "scene_id"
        case itemIndex = "item_index"
        case text
        case textPinyin = "text_pinyin"
        case textEnglish = "text_english"
        case audioUrl = "audio_url"
        case coordinates
    }

    public struct Coordinates: Codable, Hashable {
        public let x: Double // 相对比例 0.0 ~ 1.0 或百分比
        public let y: Double
        public let width: Double?
        public let height: Double?

        public init(x: Double, y: Double, width: Double? = nil, height: Double? = nil) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }
    }

    public init(
        id: String,
        sceneId: String,
        itemIndex: Int? = nil,
        text: String,
        textPinyin: String? = nil,
        textEnglish: String? = nil,
        audioUrl: String? = nil,
        coordinates: Coordinates? = nil
    ) {
        self.id = id
        self.sceneId = sceneId
        self.itemIndex = itemIndex
        self.text = text
        self.textPinyin = textPinyin
        self.textEnglish = textEnglish
        self.audioUrl = audioUrl
        self.coordinates = coordinates
    }
}
