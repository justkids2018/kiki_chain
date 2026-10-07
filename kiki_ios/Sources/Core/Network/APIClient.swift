import Foundation

/// 基于 URLSession 与 Swift Concurrency 的统一网络请求客户端
public final class APIClient {
    public static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    /// 发起网络请求并解析 APIResponse<T>
    /// - Parameters:
    ///   - endpoint: 端点定义
    ///   - queryItems: 可选的 URL Query 参数
    ///   - body: 可选的 POST/PUT 请求体数据
    /// - Returns: 解包后的核心业务数据 T
    public func request<T: Decodable>(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil
    ) async throws -> T {
        let request = try buildURLRequest(endpoint: endpoint, queryItems: queryItems, body: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("无效的 HTTP 响应")
        }

        // 处理 HTTP 状态码
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, message: "HTTP 异常状态码: \(httpResponse.statusCode)")
        }

        // 解码 JSON 响应包
        do {
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            guard apiResponse.isSuccess else {
                throw NetworkError.requestFailed(
                    statusCode: apiResponse.code ?? apiResponse.errorcode ?? httpResponse.statusCode,
                    message: apiResponse.resolvedMessage
                )
            }
            guard let payload = apiResponse.data else {
                if T.self == EmptyData.self, let empty = EmptyData() as? T {
                    return empty
                }
                throw NetworkError.decodingError("返回成功但数据体为空")
            }
            return payload
        } catch let decodingErr as DecodingError {
            // 如果服务端某些接口直接返回了 T（未包装 APIResponse），做一层容错尝试
            if let directPayload = try? decoder.decode(T.self, from: data) {
                return directPayload
            }
            throw NetworkError.decodingError(decodingErr.localizedDescription)
        }
    }

    /// 构建原生 URLRequest
    private func buildURLRequest(
        endpoint: APIEndpoint,
        queryItems: [URLQueryItem]?,
        body: Encodable?
    ) throws -> URLRequest {
        let config = APIConfiguration.shared
        guard var components = URLComponents(url: config.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL(endpoint.path)
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL(components.string ?? endpoint.path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.timeoutInterval = 15.0

        for (key, value) in config.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            } catch {
                throw NetworkError.encodingError(error.localizedDescription)
            }
        }

        return request
    }
}

/// 类型擦除的 Encodable 辅助包装
private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ wrapped: T) {
        self.encodeClosure = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
