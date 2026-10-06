import Foundation
import Combine

public struct SceneLearningProgress: Codable, Identifiable {
    public var id: String { sceneId }
    public let sceneId: String
    public let sceneName: String
    public var totalRegions: Int
    public var learnedRegions: Set<String>
    public var spokenRegions: Set<String>
    public var firstLearnedAt: Date
    public var lastLearnedAt: Date
    public var studySeconds: Int

    public var stars: Int {
        guard totalRegions > 0 else { return 0 }
        let ratio = Double(learnedRegions.count) / Double(totalRegions)
        return ratio >= 1 ? 3 : ratio >= 0.6 ? 2 : ratio >= 0.3 ? 1 : 0
    }
    public var isCompleted: Bool { totalRegions > 0 && learnedRegions.count >= totalRegions }
}

@MainActor
public final class LearningProgressStore: ObservableObject {
    public static let shared = LearningProgressStore()
    @Published public private(set) var records: [String: SceneLearningProgress] = [:]
    private let storageKey = "kiki.learning.progress.v1"
    private let userDefaults = UserDefaults.standard

    private init() { load() }

    public func progress(for sceneId: String) -> SceneLearningProgress? { records[sceneId] }

    public func refreshAccountScope() {
        let key = scopedKey
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: SceneLearningProgress].self, from: data) else {
            records = [:]
            return
        }
        records = decoded
    }

    public func markLearned(scene: Scene, regionId: String, total: Int) {
        var value = records[scene.id] ?? SceneLearningProgress(
            sceneId: scene.id, sceneName: scene.name, totalRegions: total,
            learnedRegions: [], spokenRegions: [], firstLearnedAt: .now,
            lastLearnedAt: .now, studySeconds: 0
        )
        // Use the current card's distinct vocabulary count. Older builds counted
        // individual tap polygons, which could double the denominator.
        value.totalRegions = max(total, value.learnedRegions.count)
        value.learnedRegions.insert(regionId)
        value.lastLearnedAt = .now
        records[scene.id] = value
        save()
    }

    public func restore(scene: Scene, learned: Set<String>, total: Int) {
        var value = records[scene.id] ?? SceneLearningProgress(
            sceneId: scene.id, sceneName: scene.name, totalRegions: total,
            learnedRegions: [], spokenRegions: [], firstLearnedAt: .now,
            lastLearnedAt: .now, studySeconds: 0
        )
        value.learnedRegions.formUnion(learned)
        value.totalRegions = max(total, value.learnedRegions.count)
        records[scene.id] = value
        save()
    }

    public func mergeServerProgress(sceneId: String, sceneName: String, total: Int, learned: Set<String>, stars: Int) {
        var value = records[sceneId] ?? SceneLearningProgress(
            sceneId: sceneId, sceneName: sceneName, totalRegions: total,
            learnedRegions: [], spokenRegions: [], firstLearnedAt: .now,
            lastLearnedAt: .now, studySeconds: 0
        )
        value.totalRegions = max(value.totalRegions, total)
        value.learnedRegions.formUnion(learned)
        records[sceneId] = value
        save()
    }

    public func markSpoken(scene: Scene, regionId: String, total: Int) {
        markLearned(scene: scene, regionId: regionId, total: total)
        guard var value = records[scene.id] else { return }
        value.spokenRegions.insert(regionId)
        records[scene.id] = value
        save()
    }

    private func load() {
        guard let data = userDefaults.data(forKey: scopedKey),
              let decoded = try? JSONDecoder().decode([String: SceneLearningProgress].self, from: data) else { return }
        records = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        userDefaults.set(data, forKey: scopedKey)
    }

    private var scopedKey: String {
        "\(storageKey).\(AuthViewModel.shared.currentUser?.id ?? "guest")"
    }
}
