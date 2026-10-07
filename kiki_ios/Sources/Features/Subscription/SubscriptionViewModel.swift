import Foundation
import Combine

import SwiftUI
import StoreKit

/// VIP 订阅页面 ViewModel
@MainActor
public final class SubscriptionViewModel: ObservableObject {
    @Published public private(set) var products: [SubscriptionProduct] = []
    @Published public var selectedProduct: SubscriptionProduct?
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var isPurchasing: Bool = false
    @Published public var errorMessage: String?
    @Published public var purchaseSuccess: Bool = false

    private let apiClient: APIClient
    private let authViewModel: AuthViewModel

    public init(apiClient: APIClient = .shared, authViewModel: AuthViewModel? = nil) {
        self.apiClient = apiClient
        self.authViewModel = authViewModel ?? .shared
    }

    /// 加载订阅商品列表
    public func fetchProducts() async {
        isLoading = true
        errorMessage = nil

        struct ProductsPayload: Decodable {
            let products: [SubscriptionProduct]
        }

        do {
            let payload: ProductsPayload = try await apiClient.request(endpoint: .subscriptionProducts, queryItems: [URLQueryItem(name: "region", value: "cn"), URLQueryItem(name: "platform", value: "ios"), URLQueryItem(name: "distribution_channel", value: "app_store")])
            let storeProducts = try await Product.products(for: payload.products.map(\.productId))
            let availableIDs = Set(storeProducts.map(\.id))
            self.products = payload.products.filter { availableIDs.contains($0.productId) }
            if self.products.isEmpty { self.errorMessage = "App Store Connect 尚未配置与服务端匹配的内购商品。" }
            self.selectedProduct = self.products.first(where: { $0.isRecommended }) ?? self.products.first
            self.isLoading = false
        } catch {
            self.products = []
            self.errorMessage = "暂时无法获取会员套餐，请检查网络后重试。"
            self.isLoading = false
        }
    }

    /// Create an order, purchase the matching StoreKit product, and confirm its signed transaction with the server.
    public func purchase(product: SubscriptionProduct) async -> Bool {
        isPurchasing = true
        errorMessage = nil
        struct OrderRequest: Encodable {
            let productId: String; let region: String; let platform: String; let distributionChannel: String
            enum CodingKeys: String, CodingKey { case productId = "product_id", region, platform, distributionChannel = "distribution_channel" }
        }
        struct Order: Decodable { let orderId: String; enum CodingKeys: String, CodingKey { case orderId = "order_id" } }
        struct ConfirmRequest: Encodable { let purchaseToken: String; let sandbox: Bool; enum CodingKeys: String, CodingKey { case purchaseToken = "purchase_token", sandbox } }
        struct Entitlement: Decodable { let isVip: Bool; enum CodingKeys: String, CodingKey { case isVip = "is_vip" } }
        do {
            guard authViewModel.isLoggedIn else { throw NetworkError.unauthorized }
            guard let storeProduct = try await Product.products(for: [product.productId]).first else {
                throw NetworkError.unknown("此套餐尚未在 App Store Connect 配置")
            }
            let order: Order = try await apiClient.request(endpoint: .subscriptionOrders,
                queryItems: nil,
                body: OrderRequest(productId: product.productId, region: "cn", platform: "ios", distributionChannel: "app_store"))
            let verification: VerificationResult<StoreKit.Transaction>
            switch try await storeProduct.purchase() {
            case .success(let result): verification = result
            case .userCancelled: throw NetworkError.unknown("已取消购买")
            case .pending: throw NetworkError.unknown("购买正在等待批准")
            @unknown default: throw NetworkError.unknown("App Store 返回了未知购买状态")
            }
            let transaction = try verification.payloadValue
            let sandbox = transaction.environment == StoreKit.AppStore.Environment.sandbox
            let _: EmptyData = try await apiClient.request(endpoint: .confirmOrder(orderId: order.orderId),
                body: ConfirmRequest(purchaseToken: verification.jwsRepresentation, sandbox: sandbox))
            await transaction.finish()
            let entitlement: Entitlement = try await apiClient.request(endpoint: .subscriptionEntitlement)
            guard entitlement.isVip else { throw NetworkError.unknown("订单已确认，但服务端尚未激活 VIP 权益") }
            purchaseSuccess = true
            isPurchasing = false
            return true
        } catch {
            errorMessage = "购买未完成：\(error.localizedDescription)"
            purchaseSuccess = false
            isPurchasing = false
            return false
        }
    }

}
