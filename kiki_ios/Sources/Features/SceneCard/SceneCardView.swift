import SwiftUI
import AVFoundation

private struct RewardBarFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

/// 交互式学习卡片视图（场景图 + 热区点击 + 原生发音 + 跟读录音 + AI伴学助手 + 3颗星星进阶奖励）
public struct SceneCardView: View {
    public let scene: Scene
    @State private var items: [InteractiveRegion]

    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @StateObject private var recorder = AudioRecorderManager.shared
    @ObservedObject private var progressStore = LearningProgressStore.shared

    @State private var activeItemId: String? = nil
    @State private var learnedItemIds: Set<String> = []
    @State private var spokenItemIds: Set<String> = []
    @State private var sessionLearnedItemIds: Set<String> = []
    @State private var showAiVoiceSheet: Bool = false
    @State private var showWritingPractice = false
    @State private var showSuccessCelebration: Bool = false
    @State private var displayedStars = 0
    @State private var rewardBarFrame: CGRect = .zero
    @State private var rewardFlightStart = CGPoint.zero
    @State private var rewardQueue: [(index: Int, start: CGPoint)] = []
    @State private var rewardFlightIndex: Int?
    @State private var rewardTravel: CGFloat = 0
    @State private var arrivalPulseIndex: Int?
    @State private var isRewardAnimating = false

    private let apiClient: APIClient

    private let mint = Color(red: 0, green: 0.765, blue: 0.49)

    public init(scene: Scene, items: [InteractiveRegion] = [], apiClient: APIClient = .shared) {
        self.scene = scene
        self._items = State(initialValue: items)
        self.apiClient = apiClient
    }

    private var vocabularyCount: Int {
        Set(items.filter { !excludedProgressRegion($0) }.map(\.text)).count
    }

    private var sessionStarsEarned: Int {
        guard vocabularyCount > 0 else { return 0 }
        let ratio = Double(sessionLearnedItemIds.count) / Double(vocabularyCount)
        return ratio >= 1 ? 3 : ratio >= 0.6 ? 2 : ratio >= 0.3 ? 1 : 0
    }

    public var body: some View {
        GeometryReader { screen in
            let compact = screen.size.height < 700
            let side = min(screen.size.height - 28, compact ? screen.size.width * 0.47 : screen.size.height - 34)
            let panelWidth = compact ? min(300.0, screen.size.width - side - 76) : 320.0
            ZStack {
                LinearGradient(colors: [Color(red: 0.94, green: 0.96, blue: 1), Color(red: 0.92, green: 0.97, blue: 0.94)], startPoint: .topLeading, endPoint: .bottomTrailing)
                HStack(spacing: compact ? 10 : 20) {
                    Button { dismissLearning() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(red: 0.36, green: 0.42, blue: 0.48))
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.72), in: Circle())
                            .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 2)

                    imageCanvas
                        .frame(width: side, height: side)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)

                    learningPanel
                        .frame(width: panelWidth, height: side)
                }
                .padding(.horizontal, compact ? 8 : 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                if let index = rewardFlightIndex {
                    CrystalStar(earned: true, size: 32)
                        .scaleEffect(0.65 + sin(Double(rewardTravel) * .pi) * 0.72)
                        .rotationEffect(.degrees(Double(rewardTravel) * 720))
                        .position(rewardPosition(for: index))
                        .shadow(color: .yellow.opacity(0.7), radius: 12)
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: "learning-card")
            .onPreferenceChange(RewardBarFrameKey.self) { rewardBarFrame = $0 }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showAiVoiceSheet) {
            AIVoiceAssistantView(sceneId: scene.id)
        }
        .sheet(isPresented: $showWritingPractice) {
            WritingPracticeView(title: scene.name, words: items.filter { !$0.text.isEmpty && !$0.id.localizedCaseInsensitiveContains("title") && !$0.id.localizedCaseInsensitiveContains("subtitle") })
        }
        .task {
            if items.isEmpty { await loadSceneDetails() }
            if let saved = progressStore.progress(for: scene.id) {
                learnedItemIds = saved.learnedRegions
                spokenItemIds = saved.spokenRegions
            }
            displayedStars = 0
        }
    }

    @Environment(\.dismiss) private var dismiss

    private func dismissLearning() {
        Task { await submitLearningProgress() }
        dismiss()
    }

    private var imageCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                sceneArtwork
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { point in
                        if let item = item(at: point, in: geometry.size) {
                            let origin = geometry.frame(in: .named("learning-card")).origin
                            handleTapItem(item, from: CGPoint(x: origin.x + point.x, y: origin.y + point.y))
                        }
                    }
                // Flutter deliberately keeps region outlines hidden in production.
                // The artwork itself contains the labels; taps are resolved against
                // the source polygon coordinates without drawing extra badges.
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
        }
    }

    @ViewBuilder private var sceneArtwork: some View {
        if scene.id == "local_botanical_garden",
           let image = KikiResources.image(named: "kiki_zhiwuyuan", extension: "jpg") {
            image.resizable().aspectRatio(contentMode: .fit)
        } else if let url = [scene.interactiveImage, scene.coverImage].compactMap(MediaURL.resolve).first {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                case .failure: placeholderImage
                case .empty: ZStack { placeholderImage; ProgressView() }
                @unknown default: placeholderImage
                }
            }
        } else { placeholderImage }
    }

    private var learningPanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Capsule().fill(mint).frame(width: 4, height: 18)
                Text("互动学习")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(mint)
                    .lineLimit(1)
                Spacer(minLength: 3)
                CrystalStarBar(earned: displayedStars, size: 18, pulsingIndex: arrivalPulseIndex)
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: RewardBarFrameKey.self,
                                               value: proxy.frame(in: .named("learning-card")))
                    })
                Button { showWritingPractice = true } label: {
                    Image(systemName: "printer.fill").font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 0.09, green: 0.64, blue: 0.29))
                        .frame(width: 30, height: 30)
                        .background(Color(red: 0.91, green: 0.97, blue: 0.93), in: Circle())
                        .overlay(Circle().stroke(Color(red: 0.39, green: 0.79, blue: 0.53), lineWidth: 1))
                }
            }
            .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 4)

            if let item = items.first(where: { $0.id == activeItemId }) {
                selectedVocabulary(item)
            } else {
                VStack(spacing: 9) {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(mint)
                        .frame(width: 72, height: 72)
                        .background(mint.opacity(0.08), in: Circle())
                    Text("点击图片中的词语开始学习")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.gray.opacity(0.85))
                    Text("跟着 Kiki 一起探索吧")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.gray.opacity(0.55))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.65), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 8)
    }

    private func selectedVocabulary(_ item: InteractiveRegion) -> some View {
        ScrollView {
            VStack(spacing: 7) {
                if !item.textEnglish.isEmpty {
                    Button { audioPlayer.speak(item.textEnglish, language: "en-US") } label: {
                        VStack(spacing: 4) {
                            FourLineGrid(text: item.textEnglish)
                                .frame(height: 58)
                        }
                    }
                    .buttonStyle(.plain)
                }
                if !item.textPhonetic.isEmpty {
                    Button { speakEnglish(item) } label: {
                        HStack(spacing: 5) {
                            Text("音标").foregroundStyle(.secondary)
                            Text(item.textPhonetic)
                            Image(systemName: "speaker.wave.2.fill").font(.system(size: 11))
                        }
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.35, green: 0.47, blue: 0.56))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color(red: 0.95, green: 0.96, blue: 0.97), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                HStack(spacing: 6) {
                    Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                    Text("笔顺练习").font(.system(size: 9, weight: .medium, design: .rounded)).tracking(1).foregroundStyle(Color.gray.opacity(0.55))
                    Rectangle().fill(Color.gray.opacity(0.25)).frame(height: 1)
                }.padding(.vertical, 1)
                Button { audioPlayer.speak(item.text, language: "zh-CN") } label: {
                    Label(item.textPinyin.isEmpty ? "播放中文发音" : item.textPinyin, systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(mint)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(mint.opacity(0.1), in: Capsule())
                        .overlay(Capsule().stroke(mint.opacity(0.28), lineWidth: 1))
                }.buttonStyle(.plain).frame(maxWidth: .infinity, alignment: .leading)
                strokeGrid(item)
            }
            .padding(.horizontal, 12).padding(.top, 17).padding(.bottom, 12)
        }
    }

    private func strokeGrid(_ item: InteractiveRegion) -> some View {
        let chars = Array(item.text.filter { !$0.isWhitespace }.map(String.init))
        return StrokeGlyphSequenceView(characters: chars) { character in
            audioPlayer.speak(character, language: "zh-CN")
        }
        .id(item.id)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func speakEnglish(_ item: InteractiveRegion) {
        if let url = MediaURL.resolve(item.audioEnUrl) { audioPlayer.play(url: url) }
        else { audioPlayer.speak(item.textEnglish, language: "en-US") }
    }

    private var placeholderImage: some View { OfflineSceneBackdrop(sceneName: scene.name) }

    private func handleTapItem(_ item: InteractiveRegion, from point: CGPoint) {
        let previousStars = sessionStarsEarned
        withAnimation(.spring()) {
            activeItemId = item.id
            learnedItemIds.insert(item.text)
            if !excludedProgressRegion(item) {
                sessionLearnedItemIds.insert(item.text)
                progressStore.markLearned(scene: scene, regionId: item.text, total: vocabularyCount)
            }
        }
        let nextStars = sessionStarsEarned
        if nextStars > previousStars {
            rewardQueue.append(contentsOf: (previousStars + 1...nextStars).map { (index: $0 - 1, start: point) })
            if !isRewardAnimating { Task { await playQueuedRewards() } }
        }
        if !excludedProgressRegion(item) { Task { await submitLearningProgress() } }
        playItemAudio(item)
    }

    private func rewardPosition(for index: Int) -> CGPoint {
        let target = CGPoint(
            x: rewardBarFrame.minX + CrystalStarBar.horizontalPadding + 9 + CGFloat(index) * (18 + CrystalStarBar.spacing),
            y: rewardBarFrame.midY)
        let end = rewardBarFrame.isEmpty ? CGPoint(x: rewardFlightStart.x + 160, y: 42) : target
        let t = rewardTravel
        let arc = CGFloat(sin(Double(t) * .pi) * 55)
        return CGPoint(x: rewardFlightStart.x + (end.x - rewardFlightStart.x) * t,
                       y: rewardFlightStart.y + (end.y - rewardFlightStart.y) * t - arc)
    }

    @MainActor private func playQueuedRewards() async {
        isRewardAnimating = true
        while !rewardQueue.isEmpty {
            let reward = rewardQueue.removeFirst()
            let milestone = reward.index + 1
            rewardTravel = 0
            rewardFlightStart = reward.start
            rewardFlightIndex = reward.index
            withAnimation(.easeInOut(duration: 0.9)) { rewardTravel = 1 }
            try? await Task.sleep(nanoseconds: 900_000_000)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.52)) {
                displayedStars = max(displayedStars, milestone)
                arrivalPulseIndex = milestone - 1
                rewardFlightIndex = nil
            }
            KikiResources.playStarSound(star: milestone)
            try? await Task.sleep(nanoseconds: 380_000_000)
            arrivalPulseIndex = nil
        }
        isRewardAnimating = false
    }

    private func playItemAudio(_ item: InteractiveRegion) {
        if let url = MediaURL.resolve(item.audioCnUrl) {
            audioPlayer.play(url: url)
        } else if !item.audioCnKey.isEmpty,
                  let url = KikiResources.audioURL(named: item.audioCnKey) {
            audioPlayer.play(url: url)
        } else {
            audioPlayer.speak(item.text, language: "zh-CN")
        }
    }

    private func loadSceneDetails() async {
        struct DetailResponse: Decodable {
            let items: [SceneItem]?
            let itemsData: [JSONValue]?
            enum CodingKeys: String, CodingKey {
                case items
                case itemsData = "items_data"
            }
        }

        if let bundled = scene.itemsData {
            let parsed = InteractiveRegion.parse(itemsData: bundled)
            if !parsed.isEmpty { items = parsed; await restoreProgress(); return }
        }
        if let dataFile = scene.dataFile {
            let bundled = KikiResources.interactiveRegions(named: dataFile)
            if !bundled.isEmpty { items = bundled; await restoreProgress(); return }
        }

        do {
            let detail: DetailResponse = try await apiClient.request(endpoint: .sceneDetail(sceneId: scene.id))
            if let rawItems = detail.itemsData, !rawItems.isEmpty {
                let parsed = InteractiveRegion.parse(itemsData: rawItems)
                if !parsed.isEmpty { items = parsed; await restoreProgress(); return }
            }
            if let fetchedItems = detail.items, !fetchedItems.isEmpty {
                self.items = fetchedItems.map { item in
                    InteractiveRegion(
                        id: item.id,
                        index: item.itemIndex ?? 0,
                        text: item.text,
                        textPinyin: item.textPinyin ?? "",
                        textEnglish: item.textEnglish ?? ""
                    )
                }
                await restoreProgress()
                return
            }
        } catch {}

        items = []
    }

    private func restoreProgress() async {
        guard let user = AuthViewModel.shared.currentUser else { return }
        struct ProgressPayload: Decodable {
            let learnedRegions: [String]?
            let learnedCount: Int?
            let totalRegions: Int?
            enum CodingKeys: String, CodingKey {
                case learnedRegions = "learned_regions"
                case learnedCount = "learned_count"
                case totalRegions = "total_regions"
            }
        }
        do {
            let payload: ProgressPayload = try await apiClient.request(endpoint: .sceneLearningProgress(userId: user.id, sceneId: scene.id))
            let learned = Set(payload.learnedRegions ?? [])
            learnedItemIds.formUnion(learned)
            progressStore.restore(scene: scene, learned: learned, total: max(vocabularyCount, learned.count))
        } catch { /* Offline learning continues from the locally persisted snapshot. */ }
    }

    private func excludedProgressRegion(_ item: InteractiveRegion) -> Bool {
        let key = item.id.lowercased()
        return key.contains("title") || key.contains("subtitle")
    }

    private func submitLearningProgress() async {
        guard let user = AuthViewModel.shared.currentUser,
              let progress = progressStore.progress(for: scene.id) else { return }
        struct LearnedRegion: Encodable {
            let regionId: String; let regionText: String; let regionTextEnglish: String; let learnedAt: String
            enum CodingKeys: String, CodingKey { case regionId = "region_id", regionText = "region_text", regionTextEnglish = "region_text_english", learnedAt = "learned_at" }
        }
        struct ProgressRequest: Encodable {
            let userId: String; let sceneId: String; let learnedRegions: [LearnedRegion]
            let starsEarned: Int; let isCompleted: Bool; let studyTime: Int
            enum CodingKeys: String, CodingKey { case userId = "user_id", sceneId = "scene_id", learnedRegions = "learned_regions", starsEarned = "stars_earned", isCompleted = "is_completed", studyTime = "study_time" }
        }
        let entries = items.filter { progress.learnedRegions.contains($0.text) }.map {
            LearnedRegion(regionId: $0.text, regionText: $0.text, regionTextEnglish: $0.textEnglish, learnedAt: ISO8601DateFormatter().string(from: progress.lastLearnedAt))
        }
        let body = ProgressRequest(userId: user.id, sceneId: scene.id, learnedRegions: entries,
                                   starsEarned: progress.stars, isCompleted: progress.isCompleted, studyTime: progress.studySeconds)
        do {
            let _: EmptyData = try await apiClient.request(endpoint: .submitLearningProgress, body: body)
        } catch { /* Keep the local record; the next learning action retries. */ }
    }

    private func itemCenter(_ item: InteractiveRegion, in size: CGSize) -> CGPoint? {
        guard !item.coordinates.isEmpty else { return nil }
        let sourceWidth = max(scene.imageWidth ?? 0, item.coordinates.map(\.x).max() ?? 1)
        let sourceHeight = max(scene.imageHeight ?? 0, item.coordinates.map(\.y).max() ?? 1)
        guard sourceWidth > 0, sourceHeight > 0 else { return nil }
        let scale = min(size.width / sourceWidth, size.height / sourceHeight)
        let offsetX = (size.width - sourceWidth * scale) / 2
        let offsetY = (size.height - sourceHeight * scale) / 2
        let x = item.coordinates.map(\.x).reduce(0, +) / Double(item.coordinates.count)
        let y = item.coordinates.map(\.y).reduce(0, +) / Double(item.coordinates.count)
        return CGPoint(x: offsetX + x * scale, y: offsetY + y * scale)
    }

    private func item(at point: CGPoint, in size: CGSize) -> InteractiveRegion? {
        let candidates = items.compactMap { item -> (InteractiveRegion, [CGPoint])? in
            guard !item.coordinates.isEmpty, let mapped = mappedCoordinates(item, in: size) else { return nil }
            return (item, mapped)
        }.filter { pointInRegionBounds(point, polygon: $0.1) }
        return candidates.min { polygonArea($0.1) < polygonArea($1.1) }?.0
    }

    private func mappedCoordinates(_ item: InteractiveRegion, in size: CGSize) -> [CGPoint]? {
        guard !item.coordinates.isEmpty else { return nil }
        let width = scene.imageWidth ?? (scene.id == "local_botanical_garden" ? 1728 : 1024)
        let height = scene.imageHeight ?? (scene.id == "local_botanical_garden" ? 2464 : 1024)
        guard width > 0, height > 0 else { return nil }
        let scale = min(size.width / width, size.height / height)
        let offsetX = (size.width - width * scale) / 2
        let offsetY = (size.height - height * scale) / 2
        return item.coordinates.map { CGPoint(x: offsetX + $0.x * scale, y: offsetY + $0.y * scale) }
    }

    private func pointInPolygon(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
        var inside = false
        var previous = polygon.count - 1
        for current in polygon.indices {
            let a = polygon[current], b = polygon[previous]
            if ((a.y > point.y) != (b.y > point.y)) &&
                point.x < (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x { inside.toggle() }
            previous = current
        }
        return inside
    }

    private func pointInRegionBounds(_ point: CGPoint, polygon: [CGPoint]) -> Bool {
        // Source JSON lists rectangle corners in row order, not winding order.
        // A polygon test on those four points self-intersects and misses taps.
        guard let minX = polygon.map(\.x).min(), let maxX = polygon.map(\.x).max(),
              let minY = polygon.map(\.y).min(), let maxY = polygon.map(\.y).max() else { return false }
        return CGRect(x: minX, y: minY, width: max(1, maxX - minX), height: max(1, maxY - minY))
            .insetBy(dx: -8, dy: -8).contains(point)
    }

    private func polygonArea(_ polygon: [CGPoint]) -> CGFloat {
        guard polygon.count > 2 else { return .greatestFiniteMagnitude }
        return abs(polygon.indices.reduce(0) { sum, index in
            let next = (index + 1) % polygon.count
            return sum + polygon[index].x * polygon[next].y - polygon[next].x * polygon[index].y
        }) / 2
    }
}

/// 热区标记组件
struct HotspotBadge: View {
    let text: String
    let pinyin: String?
    let isSelected: Bool
    let isLearned: Bool

    var body: some View {
        VStack(spacing: 2) {
            if let pinyin = pinyin, isSelected, !pinyin.isEmpty {
                Text(pinyin)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Text(text)
                .font(.system(size: isSelected ? 15 : 13, weight: .bold))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isSelected ? Color.orange : (isLearned ? Color.yellow.opacity(0.3) : Color.white))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(isSelected ? 1.15 : 1.0)
    }
}


private struct OfflineSceneBackdrop: View {
    let sceneName: String
    private var isClassroom: Bool { sceneName.contains("教室") || sceneName.lowercased().contains("classroom") }
    private var isZoo: Bool { sceneName.contains("动物") || sceneName.lowercased().contains("zoo") }
    private var icons: [String] {
        if isClassroom { return ["books.vertical.fill", "pencil.tip.crop.circle", "backpack.fill", "ruler.fill", "apple.logo"] }
        if isZoo { return ["pawprint.fill", "bird.fill", "hare.fill", "fish.fill", "tortoise.fill"] }
        return ["sun.max.fill", "tree.fill", "leaf.fill", "carrot.fill", "cloud.fill"]
    }
    private var colors: [Color] {
        if isClassroom { return [Color(red: 0.86, green: 0.93, blue: 0.97), Color(red: 0.95, green: 0.97, blue: 0.89)] }
        if isZoo { return [Color(red: 0.81, green: 0.92, blue: 0.76), Color(red: 0.97, green: 0.92, blue: 0.74)] }
        return [Color(red: 0.81, green: 0.93, blue: 0.79), Color(red: 0.98, green: 0.94, blue: 0.77)]
    }
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                Circle().fill(Color.yellow.opacity(0.42)).frame(width: proxy.size.width * 0.13)
                    .position(x: proxy.size.width * 0.83, y: proxy.size.height * 0.14)
                Ellipse().fill(Color.green.opacity(0.22)).frame(width: proxy.size.width * 1.15, height: proxy.size.height * 0.27)
                    .position(x: proxy.size.width * 0.34, y: proxy.size.height * 0.91)
                Ellipse().fill(Color.green.opacity(0.15)).frame(width: proxy.size.width * 0.85, height: proxy.size.height * 0.20)
                    .position(x: proxy.size.width * 0.88, y: proxy.size.height * 0.96)
                ForEach(Array(icons.enumerated()), id: \.offset) { index, icon in
                    Image(systemName: icon)
                        .font(.system(size: proxy.size.width * (index.isMultiple(of: 2) ? 0.13 : 0.10), weight: .medium))
                        .foregroundStyle(isClassroom ? Color.blue.opacity(0.14) : Color.green.opacity(0.20))
                        .position(x: proxy.size.width * [0.16, 0.43, 0.72, 0.28, 0.87][index],
                                  y: proxy.size.height * [0.30, 0.46, 0.34, 0.70, 0.67][index])
                }
                if isClassroom {
                    RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.25, green: 0.48, blue: 0.47).opacity(0.12))
                        .frame(width: proxy.size.width * 0.58, height: proxy.size.height * 0.16)
                        .position(x: proxy.size.width * 0.48, y: proxy.size.height * 0.20)
                }
            }
            .clipped()
        }
    }
}

private struct FourLineGrid: View {
    let text: String
    var body: some View {
        GeometryReader { proxy in
            let baseline = proxy.size.height * 2 / 3
            ZStack(alignment: .top) {
                Path { path in
                    for index in 0..<4 {
                        let y = proxy.size.height * CGFloat(index) / 3
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    }
                }
                .stroke(Color(red: 0.81, green: 0.83, blue: 0.83), style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                        Text(String(character))
                            .foregroundStyle("aeiouAEIOU".contains(character) ? Color(red: 0.93, green: 0.32, blue: 0.27) : Color(red: 0.22, green: 0.24, blue: 0.23))
                    }
                }
                .font(.system(size: min(33, proxy.size.width / CGFloat(max(text.count, 1)) * 1.45), weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.55)
                .lineLimit(1)
                .frame(maxWidth: proxy.size.width - 8, alignment: .center)
                .position(x: proxy.size.width / 2, y: baseline - 13)
            }
        }
    }
}

private struct TianZiGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
                path.move(to: CGPoint(x: 0, y: proxy.size.height / 2))
                path.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height / 2))
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height))
                path.move(to: CGPoint(x: proxy.size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: proxy.size.height))
            }
            .stroke(Color(red: 0.88, green: 0.75, blue: 0.63).opacity(0.48), style: StrokeStyle(lineWidth: 0.7, dash: [3, 2]))
        }
    }
}
