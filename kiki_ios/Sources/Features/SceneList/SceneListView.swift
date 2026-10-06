import SwiftUI

/// The scene picker mirrors the stacked Flutter card deck.
public struct SceneListView: View {
    @StateObject private var model: SceneListViewModel
    @State private var selectedIndex = 0
    @State private var didRestore = false
    @State private var learningScene: Scene?
    @State private var showVipAlert = false
    @State private var showSubscription = false
    @Environment(\.dismiss) private var dismiss

    private let category: SceneCategory

    public init(category: SceneCategory) {
        self.category = category
        _model = StateObject(wrappedValue: SceneListViewModel(category: category))
    }

    public var body: some View {
        GeometryReader { geometry in
            let cardSize = min(440, geometry.size.width * 0.48, max(210, (geometry.size.height - 64) * 0.79))
            ZStack {
                background.ignoresSafeArea()

                if model.isLoading && model.scenes.isEmpty {
                    ProgressView("正在加载卡片...").tint(.white).foregroundStyle(.white)
                } else if model.scenes.isEmpty {
                    emptyState
                } else {
                    deck(cardSize: cardSize, width: geometry.size.width)
                        .frame(width: geometry.size.width, height: cardSize)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.55)
                        .gesture(DragGesture(minimumDistance: 18).onEnded { value in
                            if value.translation.width < -45 { select(index: selectedIndex + 1) }
                            else if value.translation.width > 45 { select(index: selectedIndex - 1) }
                        })

                    if let scene = currentScene {
                        Text(scene.name)
                            .font(.system(size: geometry.size.height < 430 ? 20 : 24, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .padding(.horizontal, 20).padding(.vertical, 7)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.45), lineWidth: 1))
                            .shadow(color: .black.opacity(0.18), radius: 10, y: 3)
                            .position(x: geometry.size.width / 2, y: 30)

                        Text("\(selectedIndex + 1) / \(model.scenes.count)")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.white.opacity(0.92))
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(.black.opacity(0.22), in: Capsule())
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 18)
                    }
                }

                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(hex: 0xFF3F2718))
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial, in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .position(x: 34, y: 30)
                .accessibilityLabel("返回首页")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            if model.scenes.isEmpty { await model.fetchScenes() }
            restoreSelectionIfNeeded()
        }
        .onChange(of: model.scenes.count) { _ in restoreSelectionIfNeeded() }
        .fullScreenCover(item: $learningScene) { scene in
            SceneCardView(scene: scene).interactiveDismissDisabled()
        }
        .sheet(isPresented: $showSubscription) { SubscriptionView() }
        .alert("解锁完整主题", isPresented: $showVipAlert) {
            Button("立即开通") { showSubscription = true }
            Button("稍后再说", role: .cancel) {}
        } message: { Text("该卡片为会员专享，开通后即可学习。") }
    }

    @ViewBuilder private var background: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xFFF8EFDC), Color(hex: 0xFFF5E7CF)], startPoint: .top, endPoint: .bottom)
            if let scene = currentScene {
                SceneDeckArtwork(scene: scene)
                    .blur(radius: 22).scaleEffect(1.15)
                    .id(scene.id).transition(.opacity)
            }
            Color.black.opacity(currentScene == nil ? 0 : 0.34)
        }
        .animation(.easeOut(duration: 0.28), value: selectedIndex)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: model.errorMessage == nil ? "square.stack" : "wifi.exclamationmark").font(.system(size: 44))
            Text(model.errorMessage == nil ? "暂无场景" : "场景加载失败").font(.system(size: 18, weight: .bold))
            if model.errorMessage != nil {
                Button("重试") { Task { await model.fetchScenes() } }
                    .buttonStyle(.borderedProminent).tint(Color(hex: 0xFF79BF3F))
            }
        }
        .foregroundStyle(Color(hex: 0xFF3F2718))
    }

    private func deck(cardSize: CGFloat, width: CGFloat) -> some View {
        let spacing = cardSize * 0.76
        let indices = model.scenes.indices.filter { abs($0 - selectedIndex) <= 3 }
        return ZStack {
            ForEach(indices, id: \.self) { index in
                let distance = abs(index - selectedIndex)
                let active = distance == 0
                let scene = model.scenes[index]
                Button {
                    if active { open(scene) } else { select(index: index) }
                } label: {
                    SceneGlassCard(scene: scene, isActive: active)
                        .frame(width: cardSize, height: cardSize)
                        .scaleEffect(max(0.62, 1 - CGFloat(distance) * 0.12))
                        .opacity(max(0.28, 1 - Double(distance) * 0.19))
                        .offset(x: CGFloat(index - selectedIndex) * spacing)
                }
                .buttonStyle(.plain)
                .zIndex(Double(10 - distance))
                .accessibilityLabel(active ? "开始学习：\(scene.name)" : "选择场景：\(scene.name)")
            }
        }
        .frame(width: width, height: cardSize)
        .animation(.easeOut(duration: 0.28), value: selectedIndex)
    }

    private var currentScene: Scene? {
        guard model.scenes.indices.contains(selectedIndex) else { return nil }
        return model.scenes[selectedIndex]
    }

    private func restoreSelectionIfNeeded() {
        guard !didRestore, !model.scenes.isEmpty else { return }
        didRestore = true
        if let id = UserDefaults.standard.string(forKey: "scene_list_last_scene_id_\(category.id)"),
           let index = model.scenes.firstIndex(where: { $0.id == id }) {
            selectedIndex = index
        } else {
            selectedIndex = model.scenes.firstIndex {
                LearningProgressStore.shared.progress(for: $0.id)?.learnedRegions.isEmpty != false
            } ?? 0
        }
    }

    private func select(index: Int) {
        guard model.scenes.indices.contains(index) else { return }
        withAnimation(.easeOut(duration: 0.28)) { selectedIndex = index }
        UserDefaults.standard.set(model.scenes[index].id, forKey: "scene_list_last_scene_id_\(category.id)")
    }

    private func open(_ scene: Scene) {
        guard !scene.isLocked || scene.id.hasPrefix("local_") else { showVipAlert = true; return }
        UserDefaults.standard.set(scene.id, forKey: "scene_list_last_scene_id_\(category.id)")
        learningScene = scene
    }
}

private struct SceneGlassCard: View {
    let scene: Scene
    let isActive: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            SceneDeckArtwork(scene: scene)
            VStack(alignment: .leading, spacing: 2) {
                Text(scene.name).font(.system(size: 18, weight: .bold)).lineLimit(1)
                if let english = scene.nameEn, !english.isEmpty {
                    Text(english).font(.system(size: 12, weight: .medium)).lineLimit(1)
                }
            }
            .foregroundStyle(Color(hex: 0xFF3F2718))
            .padding(.horizontal, 17).padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) { Rectangle().fill(.white.opacity(0.70)).frame(height: 1) }
            if scene.isNew {
                Text("NEW").font(.system(size: 11, weight: .bold)).foregroundStyle(.white)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Color(hex: 0xFF00C37D), in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 23))
        .overlay(RoundedRectangle(cornerRadius: 23).stroke(.white.opacity(isActive ? 0.36 : 0.15), lineWidth: 0.8))
        .overlay { if !isActive { RoundedRectangle(cornerRadius: 23).fill(.black.opacity(0.25)) } }
        .shadow(color: .black.opacity(isActive ? 0.24 : 0.12), radius: isActive ? 22 : 11, y: isActive ? 11 : 5)
    }
}

private struct SceneDeckArtwork: View {
    let scene: Scene

    var body: some View {
        GeometryReader { geometry in
            Group {
                if scene.id == "local_botanical_garden",
                   let art = KikiResources.image(named: "kiki_zhiwuyuan", extension: "jpg") {
                    art.resizable().scaledToFill()
                } else if let url = [scene.coverImage, scene.interactiveImage].compactMap(MediaURL.resolve).first {
                    AsyncImage(url: url) { phase in
                        if let art = phase.image { art.resizable().scaledToFill() }
                        else { placeholder }
                    }
                } else { placeholder }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0xFF9CCB74), Color(hex: 0xFF498867)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: "photo").font(.system(size: 44, weight: .ultraLight)).foregroundStyle(.white.opacity(0.8))
        }
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: Double((hex >> 24) & 0xFF) / 255)
    }
}
