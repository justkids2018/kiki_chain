import Foundation

/// Bundled starter content keeps the learning journey usable when the service
/// is offline. Online responses replace these entries when available.
public enum LocalLearningCatalog {
    public static let categories: [SceneCategory] = [
        SceneCategory(id: "local_nature", name: "自然探索", icon: "🌱", description: "走进植物园与动物园，发现身边的自然", order: 0, sceneCount: 2, totalItemCount: 25),
        SceneCategory(id: "local_classroom", name: "校园生活", icon: "🎒", description: "在教室里认识学习用品和校园生活", order: 1, sceneCount: 1, totalItemCount: 12)
    ]

    public static let scenes: [Scene] = [
        Scene(id: "local_botanical_garden", categoryId: "local_nature", name: "植物园", nameEn: "Botanical Garden", dataFile: "kiki_zhiwuyuan.json", itemCount: 11, order: 0, imageWidth: 785, imageHeight: 1110),
        Scene(id: "local_zoo", categoryId: "local_nature", name: "动物园", nameEn: "Zoo", dataFile: "kiki_dongwuyuan.json", itemCount: 14, order: 1, imageWidth: 1381, imageHeight: 2246),
        Scene(id: "local_classroom", categoryId: "local_classroom", name: "教室", nameEn: "Classroom", dataFile: "kiki_jiaoshi.json", itemCount: 8, order: 0, imageWidth: 997, imageHeight: 1013)
    ]

    public static func scenes(in categoryId: String) -> [Scene] {
        scenes.filter { $0.categoryId == categoryId }.sorted { $0.order < $1.order }
    }
}
