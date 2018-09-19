import Foundation
import RequestKit

@objc open class User: NSObject, Codable {
    open var id: String
    open var login: String?
    open var name: String?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case login = "username"
        case name = "display_name"
    }

    public override init() {
        id = ""
        super.init()
    }
}

@objc open class Email: NSObject, Codable {
    public var isPrimary: Bool = false
    public var isConfirmed: Bool = false
    public var type: String = ""
    public var email: String = ""

    private enum CodingKeys: String, CodingKey {
        case isPrimary = "is_primary"
        case isConfirmed = "is_confirmed"
        case type
        case email
    }
}

public extension TrashCanKit {
    public func me(_ session: RequestKitURLSession = URLSession.shared, completion: @escaping (_ response: Response<User>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.readAuthenticatedUser(configuration)
        return router.load(session, expectedResultType: User.self) { user, error in
            if let error = error {
                completion(Response.failure(error))
            } else if let user = user {
                completion(Response.success(user))
            }
        }
    }

    public func emails(_ session: RequestKitURLSession = URLSession.shared, completion: @escaping (_ response: Response<[Email]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.readEmails(configuration)
        return router.load(session, expectedResultType: Page<Email>.self) { page, error in
            if let error = error {
                completion(Response.failure(error))
            } else if let page = page {
                completion(Response.success(page.values))
            }
        }
    }
}

// MARK: Router

public enum UserRouter: Router {
    case readAuthenticatedUser(Configuration)
    case readEmails(Configuration)

    public var configuration: Configuration {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .url
    }

    public var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    public var params: [String: Any] {
        return [:]
    }
}
