import SwiftUI

/// Flutter HomePage: branded top bar, account shortcuts and a horizontal 7:9 category deck.
public struct HomeView: View {
    @StateObject private var viewModel = CategoryListViewModel()
    @ObservedObject private var authViewModel = AuthViewModel.shared

    @State private var navigationPath = NavigationPath()
    @State private var showLearningRecord = false
    @State private var showProfile = false
    @State private var showSubscription = false
    @State private var showVipAlert = false

    public init() {}

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                let compactHeight = geometry.size.height < 430
                let cardHeight = max(220, min(geometry.size.height - 102, 530))
                let cardWidth = cardHeight * 7 / 9

                ZStack {
                    LinearGradient(
                        colors: [Color(hex: 0xFFF8EFDC), Color(hex: 0xFFF5E7CF)],
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea()

                    VStack(spacing: 0) {
                        homeHeader(compactHeight: compactHeight)
                            .padding(.horizontal, 10)
                            .padding(.top, 6)
                            .frame(height: 62, alignment: .top)

                        Group {
                            if viewModel.isLoading && viewModel.categories.isEmpty {
                                ProgressView("加载中...")
                                    .tint(Color(hex: 0xFF79BF3F))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if let error = viewModel.errorMessage,
                                      viewModel.categories.isEmpty {
                                loadFailure(error)
                            } else if viewModel.categories.isEmpty {
                                Text("暂无分类")
                                    .foregroundStyle(Color(hex: 0xFF7A6A5B))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: compactHeight ? 22 : 28) {
                                        ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                                            let isLocked = index > 0 && authViewModel.currentUser?.isVipActive != true
                                            Button {
                                                if isLocked {
                                                    showVipAlert = true
                                                } else {
                                                    navigationPath.append(category)
                                                }
                                            } label: {
                                                CategoryFeatureCard(category: category, isLocked: isLocked)
                                                    .frame(width: cardWidth, height: cardHeight)
                                            }
                                            .buttonStyle(CategoryPressStyle())
                                        }
                                    }
                                    .padding(.leading, 15)
                                    .padding(.trailing, 10)
                                    .frame(height: cardHeight)
                                }
                                .frame(maxHeight: .infinity)
                            }
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SceneCategory.self) { category in
                SceneListView(category: category)
            }
            .sheet(isPresented: $showLearningRecord) { LearningRecordView() }
            .sheet(isPresented: $showProfile) { ProfileView() }
            .sheet(isPresented: $showSubscription) { SubscriptionView() }
            .overlay {
                if showVipAlert {
                    VipUnlockDialog(
                        onDismiss: { showVipAlert = false },
                        onSubscribe: {
                            showVipAlert = false
                            showSubscription = true
                        }
                    )
                    .zIndex(10)
                }
            }
            .animation(.spring(response: 0.34, dampingFraction: 0.84), value: showVipAlert)
            .task {
                if viewModel.categories.isEmpty { await viewModel.fetchCategories() }
            }
        }
        .tint(Color(hex: 0xFF79BF3F))
    }

    private func homeHeader(compactHeight: Bool) -> some View {
        HStack(alignment: .center, spacing: 0) {
            KikiSVGImage(name: "hi_kiki_title_animated")
                .frame(width: compactHeight ? 180 : 240, height: compactHeight ? 60 : 80)

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    KikiSVGImage(name: "hi_kiki_star_icon")
                        .frame(width: 26, height: 26)
                    Text("\(authViewModel.currentUser?.totalStars ?? 0)")
                        .font(.custom("Fredoka-SemiBold", size: 11))
                        .foregroundStyle(Color(hex: 0xFFD48A00))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(.white.opacity(0.92), in: Capsule())
                .overlay(Capsule().stroke(Color(hex: 0xBFFFCB45), lineWidth: 1.5))
                .shadow(color: Color(hex: 0x40FFD65A), radius: 10, y: 3)

                headerAction("hi_kiki_learning_record_button", label: "学习记录") {
                    showLearningRecord = true
                }
                headerAction("hi_kiki_profile_button", label: "个人中心") {
                    showProfile = true
                }
            }
        }
    }

    private func headerAction(_ asset: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            KikiSVGImage(name: asset)
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func loadFailure(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)
            Text("加载失败").font(.headline)
            Text(error).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("重试") { Task { await viewModel.fetchCategories() } }
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CategoryFeatureCard: View {
    let category: SceneCategory
    let isLocked: Bool

    private var fallbackColor: Color {
        switch category.id {
        case "category_daily_life": Color(hex: 0xFF64A7D8)
        case "category_playground": Color(hex: 0xFFA779D8)
        case "category_numbers": Color(hex: 0xFFF3A34D)
        case "category_letters": Color(hex: 0xFF72B979)
        case "category_traditional_festivals": Color(hex: 0xFFE16B65)
        default: Color(hex: 0xFFB8B1A7)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            cover

            LinearGradient(
                stops: [.init(color: .clear, location: 0.50), .init(color: .black.opacity(0.70), location: 1)],
                startPoint: .top,
                endPoint: .bottom
            )

            if isLocked {
                Color(hex: 0xFF2B2B2B).opacity(0.38)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(category.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if let description = category.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(2)
                }

                HStack(spacing: 4) {
                    Image(systemName: "square.grid.2x2.fill").font(.system(size: 12))
                    Text("\(category.sceneCount) 个场景").font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.32), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
            }
            .padding(20)

            if category.isNew {
                Text("新")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: 0xFF00C37D), in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(16)
            }

            if isLocked {
                UnlockRibbon()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(x: 25, y: -28)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.10), radius: 40, x: 0, y: 12)
    }

    @ViewBuilder private var cover: some View {
        if let raw = category.coverImage, let url = URL(string: raw), ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    fallbackColor.opacity(0.35)
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        } else {
            ZStack {
                fallbackColor
                Text(category.icon ?? "✨").font(.system(size: 120))
            }
        }
    }
}

private struct UnlockRibbon: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill").font(.system(size: 13))
            Text("解锁").font(.system(size: 12, weight: .black))
        }
        .foregroundStyle(Color(hex: 0xFF4E2A00))
        .frame(width: 128, height: 30)
        .background(LinearGradient(colors: [Color(hex: 0xFFFFD772), Color(hex: 0xFFFFB238)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .overlay(alignment: .top) { Rectangle().fill(.white.opacity(0.58)).frame(height: 1) }
        .overlay(alignment: .bottom) { Rectangle().fill(.white.opacity(0.58)).frame(height: 1) }
        .rotationEffect(.radians(-0.72))
        .shadow(color: .black.opacity(0.24), radius: 10, y: 4)
    }
}

private struct CategoryPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: Double((hex >> 24) & 0xFF) / 255
        )
    }
}
