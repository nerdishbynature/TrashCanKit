import Foundation
import RequestKit

// MARK: model

@objc open class Repository: NSObject, Codable {
    open var id: String
    open var owner: User
    open var name: String?
    open var fullName: String?
    open var isPrivate: Bool = false
    open var repositoryDescription: String?
    open var links: Links?
    open var size: Int = 0
    open var scm: String?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "is_private"
        case repositoryDescription = "description"
        case links
        case size
        case scm
    }

    public override init() {
        id = "-1"
        owner = User()
        super.init()
    }
}

@objc open class Links: NSObject, Codable {
    open var watchers: Link?
    open var hooks: Link?
    open var clone: [Link]?
    open var selfLink: Link?
    open var html: Link?
    open var avatar: Link?
    open var commits: Link?
    open var forks: Link?
    open var downloads: Link?
    open var pullRequests: Link?

    enum CodingKeys: String, CodingKey {
        case watchers
        case hooks
        case clone
        case selfLink = "self"
        case html
        case avatar
        case commits
        case forks
        case downloads
        case pullRequests = "pullrequests"
    }
}

@objc open class Link: NSObject, Codable {
    open var href: URL?
    open var name: String?
}

// MARK: request

public enum PaginatedResponse<T> {
    case success(values: T, nextParameters: [String: String])
    case failure(Error)
}

public extension TrashCanKit {
    public func repositories(_ session: RequestKitURLSession = URLSession.shared, userName: String? = nil, nextParameters: [String: String] = [:], completion: @escaping (_ response: PaginatedResponse<[Repository]>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = RepositoryRouter.readRepositories(configuration, userName, nextParameters)
        return router.load(session, expectedResultType: Page<Repository>.self) { page, error in
            if let error = error {
                completion(PaginatedResponse.failure(error))
            }

            if let page = page {
                if let nextURL = page.next{
                    completion(PaginatedResponse.success(values: page.values, nextParameters: nextURL.URLParameters()))
                } else {
                    completion(PaginatedResponse.success(values: page.values, nextParameters: [String: String]()))
                }
            }
        }
    }

    public func repository(_ session: RequestKitURLSession = URLSession.shared, owner: String, name: String, completion: @escaping (_ response: Response<Repository>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = RepositoryRouter.readRepository(configuration, owner, name)
        return router.load(session, expectedResultType: Repository.self) { repository, error in
            if let error = error {
                completion(Response.failure(error))
            }

            if let repository = repository {
                completion(Response.success(repository))
            }
        }
    }
}

// MARK: Router

public enum RepositoryRouter: Router {
    case readRepositories(Configuration, String?, [String: String])
    case readRepository(Configuration, String, String)

    public var configuration: Configuration {
        switch self {
        case .readRepositories(let config, _, _): return config
        case .readRepository(let config, _, _): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .url
    }

    public var params: [String: Any] {
        switch self {
        case .readRepositories(_, let userName, var nextParameters):
            if let _ = userName {
                return nextParameters as [String : Any]
            } else {
                nextParameters += ["role": "member"]
                return nextParameters as [String : Any]
            }
        case .readRepository:
            return [:]
        }
    }

    public var path: String {
        switch self {
        case .readRepositories(_, let userName, _):
            if let userName = userName {
                return "repositories/\(userName)"
            } else {
                return "repositories"
            }
        case .readRepository(_, let owner, let name):
            return "repositories/\(owner)/\(name)"
        }
    }
}
