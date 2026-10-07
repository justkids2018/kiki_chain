import SwiftUI

public struct LearningRecordView: View {
    @ObservedObject private var progress = LearningProgressStore.shared
    @ObservedObject private var auth = AuthViewModel.shared
    @State private var serverRecords: [ServerLearningRecord] = []
    @State private var isLoadingServer = false
    public init() {}

    private var records: [SceneLearningProgress] {
        let local = progress.records
        let server = serverRecords.map { row in
            SceneLearningProgress(sceneId: row.sceneId, sceneName: row.sceneName ?? row.sceneId, totalRegions: row.totalRegions,
                learnedRegions: Set(row.learnedRegions), spokenRegions: [], firstLearnedAt: row.firstLearnedAt ?? row.lastLearnedAt ?? .now,
                lastLearnedAt: row.lastLearnedAt ?? row.firstLearnedAt ?? .now, studySeconds: row.studyTime)
        }
        var merged: [String: SceneLearningProgress] = [:]
        for row in server { merged[row.sceneId] = row }
        for row in local.values {
            if let old = merged[row.sceneId] {
                var copy = old
                copy.learnedRegions.formUnion(row.learnedRegions)
                copy.spokenRegions.formUnion(row.spokenRegions)
                copy.totalRegions = max(copy.totalRegions, row.totalRegions)
                if row.lastLearnedAt > copy.lastLearnedAt { copy.lastLearnedAt = row.lastLearnedAt }
                merged[row.sceneId] = copy
            } else { merged[row.sceneId] = row }
        }
        return merged.values.sorted { $0.lastLearnedAt > $1.lastLearnedAt }
    }
    private var learnedWords: Int { records.reduce(0) { $0 + $1.learnedRegions.count } }
    private var streak: Int {
        let days = Set(records.map { Calendar.current.startOfDay(for: $0.lastLearnedAt) }).sorted(by: >)
        guard let first = days.first, Calendar.current.isDateInToday(first) || Calendar.current.isDateInYesterday(first) else { return 0 }
        var count = 0
        var expected = first
        for day in days {
            guard Calendar.current.isDate(day, inSameDayAs: expected) else { break }
            count += 1
            expected = Calendar.current.date(byAdding: .day, value: -1, to: expected) ?? expected
        }
        return count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        StatCard(title: "掌握词汇", count: "\(learnedWords)", unit: "个", icon: "character.book.closed.fill", color: .orange)
                        StatCard(title: "探索场景", count: "\(records.count)", unit: "个", icon: "map.fill", color: .blue)
                        StatCard(title: "连续学习", count: "\(streak)", unit: "天", icon: "flame.fill", color: .red)
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("近期学习足迹").font(.headline).padding(.horizontal)
                        if records.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "book.closed").font(.largeTitle).foregroundStyle(.orange.opacity(0.7))
                                Text("还没有学习记录").font(.headline)
                                Text("探索一个场景并点击词条后，学习足迹会显示在这里。")
                                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 36)
                        } else {
                            ForEach(records) { record in
                                HStack(spacing: 12) {
                                    Image(systemName: record.isCompleted ? "checkmark.seal.fill" : "book.fill")
                                        .font(.title2).foregroundStyle(record.isCompleted ? .green : .orange)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(record.sceneName).font(.subheadline.bold())
                                        Text("\(record.learnedRegions.count)/\(record.totalRegions) 个词 · \(record.lastLearnedAt.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 3) {
                                        ForEach(0..<3, id: \.self) { index in
                                            CrystalStar(earned: index < record.stars, size: 15)
                                        }
                                    }
                                }
                                .padding().background(.white, in: RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal)
                            }
                        }
                    }
                    Spacer(minLength: 8)
                }.padding(.top)
            }
            .navigationTitle("成长档案")
            .background(Color(red: 0.98, green: 0.97, blue: 0.95).ignoresSafeArea())
            .refreshable { await loadServerRecords() }
            .task { await loadServerRecords() }
        }
    }
}

private struct ServerLearningRecord: Decodable {
    let sceneId: String; let sceneName: String?; let totalRegions: Int; let learnedRegions: [String]
    let firstLearnedAt: Date?; let lastLearnedAt: Date?; let studyTime: Int
    enum CodingKeys: String, CodingKey {
        case sceneId = "scene_id", sceneName = "scene_name", totalRegions = "total_regions", learnedRegions = "learned_regions"
        case firstLearnedAt = "first_learned_at", lastLearnedAt = "last_learned_at", studyTime = "total_study_time"
    }
    init(sceneId: String, sceneName: String?, totalRegions: Int, learnedRegions: [String], firstLearnedAt: Date?, lastLearnedAt: Date?, studyTime: Int) {
        self.sceneId = sceneId; self.sceneName = sceneName; self.totalRegions = totalRegions; self.learnedRegions = learnedRegions
        self.firstLearnedAt = firstLearnedAt; self.lastLearnedAt = lastLearnedAt; self.studyTime = studyTime
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sceneId = try values.decode(String.self, forKey: .sceneId)
        sceneName = try values.decodeIfPresent(String.self, forKey: .sceneName)
        totalRegions = try values.decodeIfPresent(Int.self, forKey: .totalRegions) ?? 0
        learnedRegions = try values.decodeIfPresent([String].self, forKey: .learnedRegions) ?? []
        studyTime = try values.decodeIfPresent(Int.self, forKey: .studyTime) ?? 0
        firstLearnedAt = Self.parseDate(try values.decodeIfPresent(String.self, forKey: .firstLearnedAt))
        lastLearnedAt = Self.parseDate(try values.decodeIfPresent(String.self, forKey: .lastLearnedAt))
    }
    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: raw) ?? ISO8601DateFormatter().date(from: raw)
    }
}

private extension LearningRecordView {
    func loadServerRecords() async {
        guard let user = AuthViewModel.shared.currentUser else { return }
        isLoadingServer = true
        defer { isLoadingServer = false }
        do {
            let rows: [ServerLearningRecord] = try await APIClient.shared.request(endpoint: .allLearningProgress(userId: user.id))
            let sceneNames = Dictionary(uniqueKeysWithValues: LocalLearningCatalog.scenes.map { ($0.id, $0.name) })
            let data = rows.map { row in
                ServerLearningRecord(sceneId: row.sceneId, sceneName: sceneNames[row.sceneId] ?? row.sceneName ?? row.sceneId,
                                     totalRegions: row.totalRegions, learnedRegions: row.learnedRegions,
                                     firstLearnedAt: row.firstLearnedAt, lastLearnedAt: row.lastLearnedAt, studyTime: row.studyTime)
            }
            serverRecords = data
        } catch { }
    }
}

struct StatCard: View {
    let title: String; let count: String; let unit: String; let icon: String; let color: Color
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(count).font(.title2.bold()); Text(unit).font(.caption).foregroundColor(.secondary)
            }
            Text(title).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2))
    }
}
