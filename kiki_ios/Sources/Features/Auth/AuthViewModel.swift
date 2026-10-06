import Foundation
import Combine

import SwiftUI

/// 认证与用户状态管理 ViewModel
@MainActor
public final class AuthViewModel: ObservableObject {
    public static let shared = AuthViewModel()

    @Published public private(set) var currentUser: User?
    @Published public private(set) var isLoggedIn: Bool = false
    @Published public private(set) var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let apiClient: APIClient
    private let tokenManager: TokenManager

    public init(apiClient: APIClient = .shared, tokenManager: TokenManager = .shared) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
        self.currentUser = tokenManager.getCachedUser()
        self.isLoggedIn = tokenManager.savedToken != nil
    }

    /// 使用手机号与密码登录，与服务端 `POST /auth/login` 契约保持一致。
    public func login(phone: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        struct LoginRequest: Encodable {
            let phone: String
            let password: String
        }

        do {
            let authData: AuthData = try await apiClient.request(
                endpoint: .login,
                body: LoginRequest(phone: phone, password: password)
            )

            tokenManager.save(token: authData.token, user: authData.user)
            self.currentUser = authData.user
            self.isLoggedIn = true
            LearningProgressStore.shared.refreshAccountScope()
            self.isLoading = false
            return true
        } catch let netError as NetworkError {
            self.errorMessage = netError.localizedDescription
            self.isLoading = false
            return false
        } catch {
            self.errorMessage = "登录失败: \(error.localizedDescription)"
            self.isLoading = false
            return false
        }
    }

    /// 注册后沿用 Flutter 客户端流程，立即尝试登录取得访问令牌。
    public func register(phone: String, password: String, nickname: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        struct RegisterRequest: Encodable {
            let uid: String
            let name: String
            let email: String
            let phone: String
            let password: String
            let roleType: Int

            enum CodingKeys: String, CodingKey {
                case uid, name, email, phone, password
                case roleType = "role_type"
            }
        }

        do {
            let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            let uid = "kiki_\(Int(Date().timeIntervalSince1970 * 1000))"
            let user: User = try await apiClient.request(
                endpoint: .register,
                body: RegisterRequest(
                    uid: uid,
                    name: trimmedNickname.isEmpty ? uid : trimmedNickname,
                    email: "",
                    phone: phone,
                    password: password,
                    roleType: 1
                )
            )
            currentUser = user
            LearningProgressStore.shared.refreshAccountScope()
            isLoading = false
            return await login(phone: phone, password: password)
        } catch {
            errorMessage = "注册失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    /// 退出登录
    public func logout() {
        tokenManager.clear()
        currentUser = nil
        isLoggedIn = false
        LearningProgressStore.shared.refreshAccountScope()
    }

    public func refreshCachedUser() {
        currentUser = tokenManager.getCachedUser()
        LearningProgressStore.shared.refreshAccountScope()
    }
}
