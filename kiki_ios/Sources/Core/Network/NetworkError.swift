import Foundation

/// 统一网络错误定义
public enum NetworkError: LocalizedError, Equatable {
    case invalidURL(String)
    case requestFailed(statusCode: Int, message: String)
    case decodingError(String)
    case encodingError(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case noConnection
    case timeout
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return String(format: String(localized: "无效的请求地址: %@"), url)
        case .requestFailed(let code, let message):
            return String(format: String(localized: "请求失败 (%d): %@"), code, message)
        case .decodingError(let detail):
            return String(format: String(localized: "数据解析失败: %@"), detail)
        case .encodingError(let detail):
            return String(format: String(localized: "参数编码失败: %@"), detail)
        case .unauthorized:
            return String(localized: "登录已过期，请重新登录")
        case .forbidden:
            return String(localized: "没有访问权限")
        case .notFound:
            return String(localized: "请求的资源不存在")
        case .serverError(let code):
            return String(format: String(localized: "服务器繁忙，请稍后再试 (%d)"), code)
        case .noConnection:
            return String(localized: "网络未连接，请检查网络设置")
        case .timeout:
            return String(localized: "网络请求超时，请重试")
        case .unknown(let message):
            return message
        }
    }
}
