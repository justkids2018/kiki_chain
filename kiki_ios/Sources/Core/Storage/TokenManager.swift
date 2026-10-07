import Foundation

/// Token 存储与鉴权管理器
public final class TokenManager {
    public static let shared = TokenManager()

    private let tokenKey = "kiki_auth_token"
    private let userKey = "kiki_cached_user"

    private init() {
        // 启动时将缓存 Token 同步到网络配置
        if let token = savedToken {
            APIConfiguration.shared.authToken = token
        }
    }

    /// 获取持久化的 Token
    public var savedToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    /// 保存登录鉴权信息
    public func save(token: String, user: User) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        APIConfiguration.shared.authToken = token

        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }

    /// 读取缓存的用户信息
    public func getCachedUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    /// 清理登录信息
    public func clear() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        APIConfiguration.shared.authToken = nil
    }
}
