import SwiftUI

/// Native port of kiki_web's growth-map scene list and landscape preview pane.
@MainActor
public struct GrowthMapView: View {
    let category: SceneCategory
    @StateObject private var model: SceneListViewModel
    @ObservedObject private var progress = LearningProgressStore.shared
    @State private var selectedScene: Scene?
    @State private var selectedIndex = 0
    @State private var didRestoreSelection = false
    @Environment(\.dismiss) private var dismiss

    private let nodeHeight: CGFloat = 164
    private let selectionKey: String

    public init(category: SceneCategory) {
        self.category = category
        _model = StateObject(wrappedValue: SceneListViewModel(category: category))
        selectionKey = "scene_list_last_index_\(category.id)"
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForestBackdrop()
                    .ignoresSafeArea()
                meadowLayer
                    .ignoresSafeArea()
                mapCharacters
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                if geometry.size.width < 760 {
                    mapPane
                } else {
                    HStack(spacing: 0) {
                        mapPane.frame(width: geometry.size.width * 0.60)
                        scenePreviewPane.frame(width: geometry.size.width * 0.40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .task {
                if model.scenes.isEmpty { await model.fetchScenes() }
                restoreSelectionIfNeeded()
            }
            .fullScreenCover(item: $selectedScene) { scene in
                SceneCardView(scene: scene)
                    .interactiveDismissDisabled()
            }
        }
    }

    private var mapPane: some View {
        ZStack {
            if model.isLoading && model.scenes.isEmpty {
                ProgressView("加载中...").tint(Color(hex: 0xFF79BF3F))
            } else if model.scenes.isEmpty {
                mapMessage
            } else {
                mapNodes
            }

            VStack {
                mapHeader
                Spacer()
                if let scene = currentScene {
                    Button { selectedScene = scene } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "leaf.fill")
                            Text("开始学习：\(scene.name)")
                                .lineLimit(1)
                            Spacer(minLength: 8)
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: 0xFF3F2718))
                        .padding(14)
                        .background(.white, in: Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var mapHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFF7A4A22))
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.92), in: Circle())
                    .overlay(Circle().stroke(Color(hex: 0xFFDDD0BC), lineWidth: 1.2))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            }
            .buttonStyle(.plain)

            Text(category.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(hex: 0xFF3F2718))
                .lineLimit(1)

            Spacer()
        }
        .frame(height: 54)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var mapNodes: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(model.scenes.enumerated()), id: \.element.id) { index, scene in
                        GrowthMapNode(
                            scene: scene,
                            index: index,
                            isCurrent: selectedIndex == index,
                            progress: progress.progress(for: scene.id),
                            onTap: { selectScene(scene, at: index, proxy: proxy) }
                        )
                        .frame(height: nodeHeight)
                        .id(scene.id)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 90)
                .padding(.bottom, 130)
            }
            .scrollIndicators(.hidden)
            .onChange(of: selectedIndex) { index in
                guard model.scenes.indices.contains(index) else { return }
                withAnimation(.easeOut(duration: 0.32)) {
                    proxy.scrollTo(model.scenes[index].id, anchor: .center)
                }
            }
            .onChange(of: model.scenes.count) { _ in restoreSelectionIfNeeded() }
        }
        .padding(.top, 54)
        .padding(.bottom, currentScene == nil ? 0 : 68)
    }

    private var scenePreviewPane: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)
            if let scene = currentScene {
                Text(scene.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(hex: 0xFF3F2718))

                HStack(spacing: 6) {
                    Text("已学 \(progress.progress(for: scene.id)?.learnedRegions.count ?? 0) / \(scene.itemCount) 个词")
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { star in
                            CrystalStar(earned: star < (progress.progress(for: scene.id)?.stars ?? 0), size: 16)
                        }
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(hex: 0xFF7A6A5B))

                Button { selectedScene = scene } label: {
                    scenePreview(scene)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 440, maxHeight: 440)
                        .padding(5)
                        .background(Color(hex: 0xFFFFF8E8), in: RoundedRectangle(cornerRadius: 28))
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color(hex: 0xFFE7D5AC), lineWidth: 1.4))
                        .shadow(color: Color(hex: 0xFF6C5532).opacity(0.16), radius: 16, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("开始学习 \(scene.name)")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 124)
    }

    private var mapMessage: some View {
        VStack(spacing: 14) {
            Image(systemName: model.errorMessage == nil ? "leaf" : "cloud.offline")
                .font(.system(size: 58))
                .foregroundStyle(Color(hex: 0xFF91A678))
            Text(model.errorMessage == nil ? "暂无场景" : "加载失败")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: 0xFF3F2718))
            if model.errorMessage != nil {
                Button("重试") { Task { await model.fetchScenes() } }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: 0xFF79BF3F))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var meadowLayer: some View {
        VStack {
            Spacer()
            KikiResources.image(named: "meadow_wide")?
                .resizable()
                .scaledToFill()
                .frame(height: 132)
                .clipped()
                .opacity(0.88)
                .offset(y: 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private var mapCharacters: some View {
        GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: -14) {
                mapCharacter("yuki_map", width: 125)
                mapCharacter("kiki_map", width: 114)
                    .offset(y: 15)
                mapCharacter("mimi_map", width: 88)
                    .offset(y: 30)
            }
            .opacity(0.62)
            .frame(width: proxy.size.width / 2, height: 210, alignment: .bottomLeading)
            .offset(x: proxy.size.width / 2, y: 12)
        }
        .allowsHitTesting(false)
    }

    private func mapCharacter(_ name: String, width: CGFloat) -> some View {
        Group {
            if let image = KikiResources.image(named: name) {
                image.resizable().scaledToFit().frame(width: width)
            }
        }
    }

    @ViewBuilder
    private func scenePreview(_ scene: Scene) -> some View {
        if scene.id == "local_botanical_garden",
           let image = KikiResources.image(named: "kiki_zhiwuyuan", extension: "jpg") {
            image.resizable().scaledToFill().clipShape(RoundedRectangle(cornerRadius: 22))
        } else {
            let raw = scene.interactiveImage ?? scene.coverImage ?? ""
            if let url = URL(string: raw), ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        PreviewFallback()
                    }
                }
            } else {
                PreviewFallback()
            }
        }
    }

    private var currentScene: Scene? {
        guard model.scenes.indices.contains(selectedIndex) else { return nil }
        return model.scenes[selectedIndex]
    }

    private func restoreSelectionIfNeeded() {
        guard !didRestoreSelection, !model.scenes.isEmpty else { return }
        didRestoreSelection = true
        if let sceneId = UserDefaults.standard.string(forKey: "scene_list_last_scene_id_\(category.id)"),
           let index = model.scenes.firstIndex(where: { $0.id == sceneId }) {
            selectedIndex = index
        } else {
            let firstUnlearned = model.scenes.firstIndex { progress.progress(for: $0.id)?.learnedRegions.isEmpty != false }
            selectedIndex = firstUnlearned ?? max(0, model.scenes.count - 1)
        }
        UserDefaults.standard.set(selectedIndex, forKey: selectionKey)
    }

    private func selectScene(_ scene: Scene, at index: Int, proxy: ScrollViewProxy) {
        if index == selectedIndex {
            selectedScene = scene
            return
        }
        selectedIndex = index
        UserDefaults.standard.set(index, forKey: selectionKey)
        UserDefaults.standard.set(scene.id, forKey: "scene_list_last_scene_id_\(category.id)")
    }
}

private struct GrowthMapNode: View {
    let scene: Scene
    let index: Int
    let isCurrent: Bool
    let progress: SceneLearningProgress?
    let onTap: () -> Void

    private var isLearned: Bool { !(progress?.learnedRegions.isEmpty ?? true) }
    private var isLeft: Bool { index.isMultiple(of: 2) }
    private var borderColor: Color {
        if isCurrent { return Color(hex: 0xFF6DB43F) }
        return isLearned ? Color(hex: 0xFF8DBD61) : Color(hex: 0xFFB8D694)
    }

    var body: some View {
        GeometryReader { geometry in
            let centerGap: CGFloat = geometry.size.width < 330 ? 52 : 70
            ZStack {
                Canvas { context, size in
                    let center = size.width / 2
                    var vertical = Path()
                    vertical.move(to: CGPoint(x: center, y: -4))
                    vertical.addCurve(to: CGPoint(x: center, y: size.height + 4), control1: CGPoint(x: center + 10, y: size.height * 0.28), control2: CGPoint(x: center - 10, y: size.height * 0.72))
                    let grown = isCurrent || isLearned
                    let trail = Color(hex: grown ? 0xFF78A84A : 0xFFC2CBAE).opacity(0.78)
                    context.stroke(vertical, with: .color(trail), style: StrokeStyle(lineWidth: 5.5, lineCap: .round, dash: [8, 8]))

                    let branchEnd = center + (isLeft ? -(centerGap / 2 + 27) : centerGap / 2 + 27)
                    var branch = Path()
                    branch.move(to: CGPoint(x: center, y: size.height / 2 + 6))
                    branch.addQuadCurve(to: CGPoint(x: branchEnd, y: size.height / 2 - 12), control: CGPoint(x: center + (isLeft ? -18 : 18), y: size.height / 2 - 10))
                    context.stroke(branch, with: .color(trail), style: StrokeStyle(lineWidth: 4.5, lineCap: .round, dash: [7, 7]))
                    context.fill(Path(ellipseIn: CGRect(x: center - 5, y: size.height / 2 - 1, width: 10, height: 10)), with: .color(Color(hex: 0xFFFFF2C7)))
                    context.fill(Path(ellipseIn: CGRect(x: center - 2.5, y: size.height / 2 + 1.5, width: 5, height: 5)), with: .color(trail))
                }

                HStack(spacing: centerGap) {
                    if isLeft { nodeContent } else { Spacer(minLength: 0) }
                    if isLeft { Spacer(minLength: 0) } else { nodeContent }
                }
            }
        }
    }

    private var nodeContent: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    ZStack {
                        Circle().fill(Color(hex: 0xFFFFF8E8))
                        sceneCover
                            .clipShape(Circle().inset(by: 5))
                    }
                    .frame(width: 86, height: 86)
                    .overlay(Circle().stroke(borderColor, lineWidth: isCurrent ? 5 : 4))
                    .shadow(color: borderColor.opacity(0.24), radius: isCurrent ? 18 : 10, y: 5)
                    .scaleEffect(isCurrent ? 1.04 : 1)
                    .animation(isCurrent ? .easeInOut(duration: 0.75).repeatForever(autoreverses: true) : .default, value: isCurrent)

                    if isLearned {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color(hex: 0xFF66AD3D), in: Circle())
                            .overlay(Circle().stroke(Color(hex: 0xFFFFF8E8), lineWidth: 3))
                    } else if scene.isNew {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0xFF5A3917))
                            .frame(width: 26, height: 26)
                            .background(Color(hex: 0xFFFFC84A), in: Circle())
                    }
                }

                Text(scene.name)
                    .font(.system(size: 16, weight: isCurrent ? .heavy : .bold))
                    .foregroundStyle(Color(hex: 0xFF3F2718))
                    .lineLimit(1)
                    .frame(maxWidth: 170, alignment: isLeft ? .trailing : .leading)

                HStack(spacing: 1) {
                    if isLearned {
                        ForEach(0..<3, id: \.self) { star in
                            CrystalStar(earned: star < (progress?.stars ?? 0), size: 16)
                        }
                    } else {
                        Image(systemName: "leaf")
                            .foregroundStyle(Color(hex: 0xFF9DBA7D))
                    }
                }
                .font(.system(size: 17))
                .frame(width: 140, alignment: isLeft ? .trailing : .leading)
            }
            .frame(maxWidth: 170)
            .opacity(isCurrent ? 1 : 0.84)
            .scaleEffect(isCurrent ? 1 : 1)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: isLeft ? .trailing : .leading)
    }

    @ViewBuilder private var sceneCover: some View {
        if let raw = scene.coverImage, let url = URL(string: raw), ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            AsyncImage(url: url) { phase in
                if let image = phase.image { image.resizable().scaledToFill() }
                else { fallbackCover }
            }
        } else {
            fallbackCover
        }
    }

    private var fallbackCover: some View {
        ZStack {
            Color(hex: 0xFFDDECC7)
            Image(systemName: "leaf.fill").font(.system(size: 28)).foregroundStyle(Color(hex: 0xFF6DA443))
        }
    }
}

private struct PreviewFallback: View {
    var body: some View {
        ZStack {
            Color(hex: 0xFFE5EFCF)
            Image(systemName: "photo")
                .font(.system(size: 58))
                .foregroundStyle(Color(hex: 0xFF78A44F))
        }
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }
}

private struct ForestBackdrop: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Color(hex: 0xFFF8F0DA), Color(hex: 0xFFE8EBCB), Color(hex: 0xFFD6E3B5)], startPoint: .top, endPoint: .bottom)
                Circle().fill(Color(hex: 0x57FFD984)).frame(width: 152, height: 152).position(x: proxy.size.width * 0.83, y: proxy.size.height * 0.14)
                ForEach(0..<7, id: \.self) { index in
                    HStack {
                        Circle().fill(Color(hex: 0x4DAFC887)).frame(width: 108 + CGFloat(index % 2) * 32)
                        Spacer()
                        Circle().fill(Color(hex: index.isMultiple(of: 2) ? 0x4DAFC887 : 0x2E7EAA59)).frame(width: 92 + CGFloat((index + 1) % 3) * 24)
                    }
                    .position(x: proxy.size.width / 2, y: proxy.size.height * (0.18 + CGFloat(index) * 0.13))
                }
                Ellipse().fill(Color(hex: 0x599DB96E))
                    .frame(width: proxy.size.width * 1.1, height: proxy.size.height * 0.22)
                    .position(x: proxy.size.width * 0.52, y: proxy.size.height * 0.95)
            }
            .clipped()
        }
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255, opacity: Double((hex >> 24) & 0xFF) / 255)
    }
}
