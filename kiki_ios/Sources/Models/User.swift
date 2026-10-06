import Foundation

/// 用户实体模型
public struct User: Codable, Identifiable, Hashable {
    public let id: String
    public let phone: String
    public let nickname: String
    public let avatar: String?
    public let totalStars: Int
    public let isVip: Bool
    public let vipExpireAt: String?
    public let email: String?
    public let createdAt: String?
    public let lastLoginAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case phone
        case nickname
        case name
        case avatar
        case totalStars = "total_stars"
        case isVip = "is_vip"
        case vipExpireAt = "vip_expire_at"
        case email
        case createdAt = "created_at"
        case lastLoginAt = "last_login_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
            ?? container.decode(String.self, forKey: .uid)
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
            ?? container.decodeIfPresent(String.self, forKey: .name)
            ?? ""
        avatar = try container.decodeIfPresent(String.self, forKey: .avatar)
        totalStars = try container.decodeIfPresent(Int.self, forKey: .totalStars) ?? 0
        isVip = try container.decodeIfPresent(Bool.self, forKey: .isVip) ?? false
        vipExpireAt = try container.decodeIfPresent(String.self, forKey: .vipExpireAt)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        lastLoginAt = try container.decodeIfPresent(String.self, forKey: .lastLoginAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(phone, forKey: .phone)
        try container.encode(nickname, forKey: .nickname)
        try container.encodeIfPresent(avatar, forKey: .avatar)
        try container.encode(totalStars, forKey: .totalStars)
        try container.encode(isVip, forKey: .isVip)
        try container.encodeIfPresent(vipExpireAt, forKey: .vipExpireAt)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(lastLoginAt, forKey: .lastLoginAt)
    }

    public init(
        id: String,
        phone: String,
        nickname: String,
        avatar: String? = nil,
        totalStars: Int = 0,
        isVip: Bool = false,
        vipExpireAt: String? = nil,
        email: String? = nil,
        createdAt: String? = nil,
        lastLoginAt: String? = nil
    ) {
        self.id = id
        self.phone = phone
        self.nickname = nickname
        self.avatar = avatar
        self.totalStars = totalStars
        self.isVip = isVip
        self.vipExpireAt = vipExpireAt
        self.email = email
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }

    /// 计算 VIP 是否在有效期内
    public var isVipActive: Bool {
        guard isVip else { return false }
        guard let expireStr = vipExpireAt, !expireStr.isEmpty else { return isVip }
        let formatter = ISO8601DateFormatter()
        if let expireDate = formatter.date(from: expireStr) {
            return expireDate > Date()
        }
        return true
    }
}

/// 登录/注册鉴权响应
public struct AuthData: Decodable {
    public let token: String
    public let refreshToken: String?
    public let user: User

    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
        case user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        if let nestedUser = try container.decodeIfPresent(User.self, forKey: .user) {
            user = nestedUser
        } else {
            user = try User(from: decoder)
        }
    }
}
