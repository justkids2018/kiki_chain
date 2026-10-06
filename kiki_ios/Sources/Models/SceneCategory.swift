import Foundation

/// 场景分类模型（严格对齐 kiki_server SceneCategoryDto）
public struct SceneCategory: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let icon: String?
    public let coverImage: String?
    public let description: String?
    public let order: Int
    public let isNew: Bool
    public let sceneCount: Int
    public let totalItemCount: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case coverImage = "cover_image"
        case description
        case order
        case isNew = "is_new"
        case sceneCount = "scene_count"
        case totalItemCount = "total_item_count"
    }

    public init(
        id: String,
        name: String,
        icon: String? = nil,
        coverImage: String? = nil,
        description: String? = nil,
        order: Int = 0,
        isNew: Bool = false,
        sceneCount: Int = 0,
        totalItemCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.coverImage = coverImage
        self.description = description
        self.order = order
        self.isNew = isNew
        self.sceneCount = sceneCount
        self.totalItemCount = totalItemCount
    }
}
