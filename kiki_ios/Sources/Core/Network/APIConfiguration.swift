import Foundation

/// API 环境与全局配置
public struct APIConfiguration {
    public static var shared = APIConfiguration()

    /// 服务端基础地址
    public var baseURL: URL

    /// 用户认证 Token
    public var authToken: String?

    /// 客户端版本与平台标头
    public var appVersion: String
    public var platform: String = "iOS"

    public init(
        baseURL: URL = URL(string: "https://kiki.keepthinking.me")!,
        authToken: String? = nil,
        appVersion: String = "1.0.0"
    ) {
        self.baseURL = baseURL
        self.authToken = authToken
        self.appVersion = appVersion
    }

    /// 获取默认请求头
    public var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Client-Platform": platform,
            "X-Client-Version": appVersion
        ]
        if let token = authToken, !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
}
