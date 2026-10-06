import Foundation

/// 统一 API 响应封包结构
/// 兼顾标准 { code: 200, message: "...", data: ... } 与 { success: true, message: "...", data: ... }
public struct APIResponse<T: Decodable>: Decodable {
    public let code: Int?
    public let success: Bool?
    public let message: String?
    public let data: T?
    public let errorcode: Int?

    public var isSuccess: Bool {
        if let success = success { return success }
        if let code = code { return code == 200 || code == 201 }
        return true
    }

    public var resolvedMessage: String {
        return message ?? "操作成功"
    }
}

public struct EmptyData: Decodable {}
