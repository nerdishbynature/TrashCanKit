import Foundation
import RequestKit

// MARK: model

@objc public class Repository: NSObject {
    public let id: String
    public let owner: User
    public var name: String?
    public var fullName: String?
    public var isPrivate: Bool
    public var repositoryDescription: String?
    public var gitURL: String?
    public var sshURL: String?
    public var cloneURL: String?
    public var size: Int

    public init(json: [String: AnyObject]) {
        owner = User(json["owner"] as? [String: AnyObject] ?? [:])
        if let id = json["uuid"] as? String {
            self.id = id
            name = json["name"] as? String
            fullName = json["full_name"] as? String
            isPrivate = json["is_private"] as? Bool ?? false
            repositoryDescription = json["description"] as? String
            if let linksDict = json["links"] as? [String: AnyObject],
                cloneArray = linksDict["clone"] as? [[String: String]] {
                for urlDict in cloneArray {
                    if urlDict["name"] == "https" {
                        let prefix = "https://\(owner.login ?? "")@"
                        gitURL = urlDict["href"]?.stringByReplacingOccurrencesOfString(prefix, withString: "git://")
                        cloneURL = urlDict["href"]?.stringByReplacingOccurrencesOfString(prefix, withString: "https://")
                    }
                    if urlDict["name"] == "ssh" {
                        sshURL = urlDict["href"]?.stringByReplacingOccurrencesOfString("ssh://", withString: "")
                    }
                }
            }
            size = json["size"] as? Int ?? 0
        } else {
            id = "-1"
            isPrivate = false
            size = 0
        }
    }
}

// MARK: request

public enum PaginatedResponse<T> {
    case Success(values: T, nextParameters: [String: String])
    case Failure(ErrorType)
}

public extension TrashCanKit {
    public func repositories(session: RequestKitURLSession = NSURLSession.sharedSession(), userName: String? = nil, nextParameters: [String: String] = [:], completion: (response: PaginatedResponse<[Repository]>) -> Void) {
        let router = RepositoryRouter.ReadRepositories(configuration, userName, nextParameters)
        router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: PaginatedResponse.Failure(error))
            }

            if let json = json, values = json["values"] as? [[String: AnyObject]] {
                let repos = values.map { Repository(json: $0) }
                if let nextURL = json["next"] as? String, parameterString = nextURL.componentsSeparatedByString("?").last {
                    completion(response: PaginatedResponse.Success(values: repos, nextParameters: parameterString.tkk_queryParameters))
                } else {
                    completion(response: PaginatedResponse.Success(values: repos, nextParameters: [String: String]()))
                }
            }
        }
    }

    public func repository(session: RequestKitURLSession = NSURLSession.sharedSession(), owner: String, name: String, completion: (response: Response<Repository>) -> Void) {
        let router = RepositoryRouter.ReadRepository(configuration, owner, name)
        router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: Response.Failure(error))
            }

            if let json = json {
                let repo =  Repository(json: json)
                completion(response: Response.Success(repo))
            }
        }
    }
}

// MARK: Router

public enum RepositoryRouter: Router {
    case ReadRepositories(Configuration, String?, [String: String])
    case ReadRepository(Configuration, String, String)

    public var configuration: Configuration {
        switch self {
        case .ReadRepositories(let config, _, _): return config
        case .ReadRepository(let config, _, _): return config
        }
    }

    public var method: HTTPMethod {
        return .GET
    }

    public var encoding: HTTPEncoding {
        return .URL
    }

    public var params: [String: AnyObject] {
        switch self {
        case .ReadRepositories(_, let userName, var nextParameters):
            if let _ = userName {
                return nextParameters
            } else {
                nextParameters += ["role": "member"]
                return nextParameters
            }
        case .ReadRepository:
            return [:]
        }
    }

    public var path: String {
        switch self {
        case .ReadRepositories(_, let userName, _):
            if let userName = userName {
                return "repositories/\(userName)"
            } else {
                return "repositories"
            }
        case .ReadRepository(_, let owner, let name):
            return "repositories/\(owner)/\(name)"
        }
    }
}
