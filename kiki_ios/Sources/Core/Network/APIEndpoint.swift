import Foundation

/// API 路径端点枚举（严格对齐 docs/api/ 与 kiki_server 路由）
public enum APIEndpoint {
    // 认证相关
    case login
    case register
    case refreshToken
    case verifyToken
    case logout

    // 用户与反馈
    case userProfile
    case updateUserProfile
    case feedback

    // 场景分类与场景
    case sceneCategories
    case sceneSearch(keyword: String)
    case sceneRecommendations
    case scenesByCategory(categoryId: String)
    case sceneDetail(sceneId: String)

    // 学习记录与进度
    case learningRecords(page: Int, pageSize: Int)
    case updateProgress
    case sceneLearningProgress(userId: String, sceneId: String)
    case allLearningProgress(userId: String)
    case userLearningSummary(userId: String)
    case submitLearningProgress
    // 会员与订阅
    case subscriptionProducts
    case subscriptionEntitlement
    case subscriptionOrders
    case confirmOrder(orderId: String)

    // AI 伴学助手
    case aiVoiceRecommendation
    case aiVoiceCreateSession
    case aiVoiceChat

    public var path: String {
        switch self {
        case .login:
            return "/api/v1/auth/login"
        case .register:
            return "/api/v1/auth/register"
        case .refreshToken:
            return "/api/v1/auth/refresh-token"
        case .verifyToken:
            return "/api/v1/auth/verify"
        case .logout:
            return "/api/v1/auth/logout"

        case .userProfile:
            return "/api/v1/mobile/user/profile"
        case .updateUserProfile:
            return "/api/v1/mobile/user/profile"
        case .feedback:
            return "/api/v1/mobile/feedback"

        case .sceneCategories:
            return "/api/v1/mobile/scene/categories"
        case .sceneSearch:
            return "/api/v1/mobile/scene/search"
        case .sceneRecommendations:
            return "/api/v1/mobile/scene/recommendations"
        case .scenesByCategory(let id):
            return "/api/v1/mobile/scene/categories/\(id)/scenes"
        case .sceneDetail(let id):
            return "/api/v1/mobile/scene/\(id)"

        case .learningRecords:
            return "/api/v1/learning/records"
        case .updateProgress:
            return "/api/v1/learning/progress"
        case .sceneLearningProgress(let userId, let sceneId):
            return "/api/v1/learning/progress/\(userId)/\(sceneId)"
        case .allLearningProgress(let userId):
            return "/api/v1/learning/progress/user/\(userId)/all"
        case .userLearningSummary(let userId):
            return "/api/v1/learning/user/\(userId)/summary"
        case .submitLearningProgress:
            return "/api/v1/learning/progress/batch"
        case .subscriptionProducts:
            return "/api/v1/mobile/subscriptions/products"
        case .subscriptionEntitlement:
            return "/api/v1/mobile/subscriptions/entitlement"
        case .subscriptionOrders:
            return "/api/v1/mobile/subscriptions/orders"
        case .confirmOrder(let id):
            return "/api/v1/mobile/subscriptions/orders/\(id)/confirm"

        case .aiVoiceRecommendation:
            return "/api/v1/ai-voice/recommendation"
        case .aiVoiceCreateSession:
            return "/api/v1/ai-voice/sessions"
        case .aiVoiceChat:
            return "/api/v1/ai-voice/chat"
        }
    }

    public var method: String {
        switch self {
        case .login, .register, .feedback, .updateProgress, .updateUserProfile, .submitLearningProgress, .subscriptionOrders, .confirmOrder,
             .refreshToken, .verifyToken, .logout, .aiVoiceCreateSession, .aiVoiceChat:
            return "POST"
        default:
            return "GET"
        }
    }
}
