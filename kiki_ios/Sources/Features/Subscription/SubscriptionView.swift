import SwiftUI

/// VIP 订阅付费墙页面
public struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部金黄色皇冠与标题
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 88, height: 88)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.yellow)
                        }

                        Text("升级 Kiki VIP 会员")
                            .font(.title2.bold())
                            .foregroundColor(.primary)

                        Text("解锁全套沉浸式互动场景，点亮孩子的语言天赋")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 16)

                    // 会员权益清单
                    VStack(spacing: 14) {
                        PrivilegeRow(icon: "sparkles.tv.fill", title: "100+ 场景随心畅学", desc: "涵盖生活认知、幼小衔接全部分级卡片")
                        PrivilegeRow(icon: "waveform.circle.fill", title: "AI 语音伴学助手", desc: "智能引导互动，随时对话激发表达兴趣")
                        PrivilegeRow(icon: "star.bubble.fill", title: "实时发音测评与反馈", desc: "原生录音智能评测，助力孩子标准发音")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.99, green: 0.98, blue: 0.94))
                    )
                    .padding(.horizontal)

                    // 订阅套餐选择
                    VStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView("正在读取 App Store 套餐…").padding(.vertical, 20)
                        } else if viewModel.products.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle").foregroundStyle(.orange)
                                Text(viewModel.errorMessage ?? "当前没有可购买的套餐").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                                Button("重新加载") { Task { await viewModel.fetchProducts() } }.buttonStyle(.bordered)
                            }.frame(maxWidth: .infinity).padding()
                        }
                        ForEach(viewModel.products) { product in
                            ProductOptionCard(
                                product: product,
                                isSelected: viewModel.selectedProduct?.productId == product.productId
                            ) {
                                viewModel.selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 购买按钮
                    VStack(spacing: 12) {
                        Button {
                            if let p = viewModel.selectedProduct {
                                Task {
                                    let success = await viewModel.purchase(product: p)
                                    if success {
                                        dismiss()
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isPurchasing {
                                    ProgressView().tint(.white)
                                }
                        Text("立即开通 (\(viewModel.selectedProduct?.displayPrice ?? "—"))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .disabled(viewModel.isPurchasing || viewModel.selectedProduct == nil)

                        if let error = viewModel.errorMessage, !viewModel.products.isEmpty {
                            Text(error).font(.caption).foregroundStyle(.red).multilineTextAlignment(.center)
                        }

                        Text("可随时在 App Store 账户设置中取消订阅")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .task {
                await viewModel.fetchProducts()
            }
        }
    }
}

struct PrivilegeRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

struct ProductOptionCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.title)
                            .font(.headline)
                        if product.isRecommended {
                            Text("最划算")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.orange))
                        }
                    }
                    if product.trialDays > 0 {
                        Text("包含 \(product.trialDays) 天免费试用")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.title2.bold())
                    .foregroundColor(isSelected ? .orange : .primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    .background(RoundedRectangle(cornerRadius: 16).fill(isSelected ? Color.orange.opacity(0.05) : Color.white))
            )
        }
        .buttonStyle(.plain)
    }
}
