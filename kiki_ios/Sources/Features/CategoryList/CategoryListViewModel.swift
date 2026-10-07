import Foundation
import Combine

import SwiftUI

/// 场景分类列表 ViewModel
@MainActor
public final class CategoryListViewModel: ObservableObject {
    @Published public private(set) var categories: [SceneCategory] = []
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isUsingOfflineCatalog = false

    private let apiClient: APIClient

    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    /// 加载分类数据 (GET /api/v1/mobile/scene/categories)
    public func fetchCategories() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedCategories: [SceneCategory] = try await apiClient.request(endpoint: .sceneCategories)
            self.categories = fetchedCategories.sorted { $0.order < $1.order }
            self.isUsingOfflineCatalog = false
            self.isLoading = false
        } catch let netError as NetworkError {
            useOfflineCatalog(after: netError.localizedDescription)
            self.isLoading = false
        } catch {
            useOfflineCatalog(after: error.localizedDescription)
            self.isLoading = false
        }
    }

    private func useOfflineCatalog(after message: String) {
        guard !LocalLearningCatalog.categories.isEmpty else {
            errorMessage = message
            return
        }
        categories = LocalLearningCatalog.categories
        isUsingOfflineCatalog = true
        errorMessage = nil
    }
}
