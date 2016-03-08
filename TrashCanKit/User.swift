import Foundation
import RequestKit

@objc public class User: NSObject {
    public let id: String?
    public var login: String
    public var name: String?

    public init(_ json: [String: AnyObject]) {
        if let username = json["username"] as? String {
            id = json["uuid"] as? String
            login = username
            name = json["display_name"] as? String
        } else {
            id = "-1"
            login = ""
        }
    }
}

@objc public class Email: NSObject {
    public let isPrimary: Bool
    public let isConfirmed: Bool
    public var type: String?
    public var email: String?

    public init(json: [String: AnyObject]) {
        if let _ = json["email"] as? String {
            isPrimary = json["is_primary"] as? Bool ?? false
            isConfirmed = json["is_confirmed"] as? Bool ?? false
            type = json["type"] as? String
            email = json["email"] as? String
        } else {
            isPrimary = false
            isConfirmed = false
        }
        super.init()
    }
}

public extension TrashCanKit {
    public func me(completion: (response: Response<User>) -> Void) {
        let router = UserRouter.ReadAuthenticatedUser(configuration)
        router.loadJSON([String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let json = json {
                    let parsedUser = User(json)
                    completion(response: Response.Success(parsedUser))
                }
            }
        }
    }

    public func emails(completion: (response: Response<[Email]>) -> Void) {
        let router = UserRouter.ReadEmails(configuration)
        router.loadJSON([String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            } else {
                if let json = json, values = json["values"] as? [[String: AnyObject]] {
                    let emails = values.map({ Email(json: $0) })
                    completion(response: Response.Success(emails))
                }
            }
        }
    }
}

// MARK: Router

public enum UserRouter: Router {
    case ReadAuthenticatedUser(Configuration)
    case ReadEmails(Configuration)

    public var configuration: Configuration {
        switch self {
        case .ReadAuthenticatedUser(let config): return config
        case .ReadEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .URL
    }

    public var path: String {
        switch self {
        case .ReadAuthenticatedUser:
            return "user"
        case .ReadEmails:
            return "user/emails"
        }
    }

    public var params: [String: String] {
        return [:]
    }
}
