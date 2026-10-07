import Foundation
import Combine

import SwiftUI

/// 某主题下的场景列表 ViewModel
@MainActor
public final class SceneListViewModel: ObservableObject {
    public let category: SceneCategory

    @Published public private(set) var scenes: [Scene] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?

    private let apiClient: APIClient

    public init(category: SceneCategory, apiClient: APIClient = .shared) {
        self.category = category
        self.apiClient = apiClient
    }

    /// 加载指定主题下的场景列表 (GET /api/v1/mobile/scene/categories/:id/scenes)
    public func fetchScenes() async {
        isLoading = true
        errorMessage = nil

        if category.id.hasPrefix("local_") {
            scenes = LocalLearningCatalog.scenes(in: category.id)
            isLoading = false
            return
        }

        do {
            let fetchedScenes: [Scene] = try await apiClient.request(
                endpoint: .scenesByCategory(categoryId: category.id)
            )
            self.scenes = fetchedScenes.sorted { $0.order < $1.order }
            self.isLoading = false
        } catch let netError as NetworkError {
            useOfflineScenes(after: netError.localizedDescription)
            self.isLoading = false
        } catch {
            useOfflineScenes(after: error.localizedDescription)
            self.isLoading = false
        }
    }

    private func useOfflineScenes(after message: String) {
        let matching = LocalLearningCatalog.scenes.filter { $0.name == category.name }
        if !matching.isEmpty {
            scenes = matching
        } else if scenes.isEmpty {
            errorMessage = message
        }
    }
}
