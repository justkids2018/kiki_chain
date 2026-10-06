import Foundation

/// 学习场景模型（严格对齐 kiki_server SceneDto）
public struct Scene: Codable, Identifiable, Hashable {
    public let id: String
    public let categoryId: String
    public let categoryIds: [String]
    public let name: String
    public let nameEn: String?
    public let coverImage: String?
    public let interactiveImage: String?
    public let description: String?
    public let context: String?
    public let dataFile: String?
    public let itemCount: Int
    public let order: Int
    public let isNew: Bool
    public let isFree: Bool
    public let requiresVip: Bool
    public let isLocked: Bool
    public let imageWidth: Double?
    public let imageHeight: Double?
    public let itemsData: [JSONValue]?

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case categoryIds = "category_ids"
        case name
        case nameEn = "name_en"
        case coverImage = "cover_image"
        case interactiveImage = "interactive_image"
        case description
        case context
        case dataFile = "data_file"
        case itemCount = "item_count"
        case order
        case isNew = "is_new"
        case isFree = "is_free"
        case requiresVip = "requires_vip"
        case isLocked = "is_locked"
        case imageWidth = "image_width"
        case imageHeight = "image_height"
        case itemsData = "items_data"
    }

    public init(
        id: String,
        categoryId: String,
        categoryIds: [String] = [],
        name: String,
        nameEn: String? = nil,
        coverImage: String? = nil,
        interactiveImage: String? = nil,
        description: String? = nil,
        context: String? = nil,
        dataFile: String? = nil,
        itemCount: Int = 0,
        order: Int = 0,
        isNew: Bool = false,
        isFree: Bool = true,
        requiresVip: Bool = false,
        isLocked: Bool = false,
        imageWidth: Double? = nil,
        imageHeight: Double? = nil,
        itemsData: [JSONValue]? = nil
    ) {
        self.id = id
        self.categoryId = categoryId
        self.categoryIds = categoryIds.isEmpty ? [categoryId] : categoryIds
        self.name = name
        self.nameEn = nameEn
        self.coverImage = coverImage
        self.interactiveImage = interactiveImage
        self.description = description
        self.context = context
        self.dataFile = dataFile
        self.itemCount = itemCount
        self.order = order
        self.isNew = isNew
        self.isFree = isFree
        self.requiresVip = requiresVip
        self.isLocked = isLocked
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.itemsData = itemsData
    }
}
