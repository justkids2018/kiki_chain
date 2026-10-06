import SwiftUI

/// 分类列表主视图
@MainActor
public struct CategoryListView: View {
    @StateObject private var viewModel: CategoryListViewModel
    public var onSelectCategory: ((SceneCategory) -> Void)?

    public init(
        viewModel: CategoryListViewModel? = nil,
        onSelectCategory: ((SceneCategory) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel ?? CategoryListViewModel())
        self.onSelectCategory = onSelectCategory
    }

    public var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()

            Group {
                if viewModel.isLoading && viewModel.categories.isEmpty {
                    ProgressView("正在加载主题...")
                        .tint(.orange)
                } else if let error = viewModel.errorMessage, viewModel.categories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("重新尝试") {
                            Task { await viewModel.fetchCategories() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.categories) { category in
                                NavigationLink(destination: GrowthMapView(category: category)) {
                                    CategoryCardView(category: category) {
                                        onSelectCategory?(category)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.fetchCategories()
                    }
                }
            }
        }
        .navigationTitle("探索主题")
        .task {
            if viewModel.categories.isEmpty {
                await viewModel.fetchCategories()
            }
        }
    }
}

/// 单个主题卡片组件
struct CategoryCardView: View {
    let category: SceneCategory
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // 封面或图标占位
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 64, height: 64)

                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if category.isNew {
                        Text("NEW")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.red))
                    }
                }

                if let desc = category.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text("\(category.sceneCount) 个场景 · \(category.totalItemCount) 个词条")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        )
    }
}
