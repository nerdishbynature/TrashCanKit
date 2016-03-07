import Foundation
import RequestKit

@objc public class PullRequest: NSObject {
    public var id: String
    public var pullRequestDescription: String?
    public var title: String?
    public var state: String?
    public var author: User?
    
    public init(json: [String: AnyObject]) {
        if let id = json["id"] {
            self.id = String(id)
            title = json["title"] as? String
            pullRequestDescription = json["description"] as? String
            state = json["state"] as? String
            author = User(json["author"] as? [String: AnyObject] ?? [:])
        } else {
            id = "-1"
        }
    }
}

// MARK: request

public extension TrashCanKit {
    public func pullRequests(owner: String, repoSlug: String, nextParameters: [String: String] = [:], completion: (response: PaginatedResponse<[PullRequest]>) -> Void) {
        let router = PullRequestRouter.ReadPullRequests(configuration, owner, repoSlug, nextParameters)
        router.loadJSON([String: AnyObject].self) { json, error in
            if let error = error {
                completion(response: PaginatedResponse.Failure(error))
            }
            
            if let json = json, values = json["values"] as? [[String: AnyObject]] {
                let repos = values.map { PullRequest(json: $0) }
                if let nextURL = json["next"] as? String, parameterString = nextURL.componentsSeparatedByString("?").last {
                    completion(response: PaginatedResponse.Success(values: repos, nextParameters: parameterString.tkk_queryParameters))
                } else {
                    completion(response: PaginatedResponse.Success(values: repos, nextParameters: [String: String]()))
                }
            }
        }
    }
}

// MARK: Router

public enum PullRequestRouter: Router {
    case ReadPullRequests(Configuration, String, String, [String: String])
    
    public var configuration: Configuration {
        switch self {
        case .ReadPullRequests(let config, _, _, _): return config
        }
    }
    
    public var method: HTTPMethod {
        return .GET
    }
    
    public var encoding: HTTPEncoding {
        return .URL
    }
    
    public var params: [String: String] {
        switch self {
        case .ReadPullRequests(_, _, _, let nextParameters):
            return nextParameters
        }
    }
    
    public var path: String {
        switch self {
        case .ReadPullRequests(_, let owner, let repoSlug, _):
            return "/repositories/\(owner)/\(repoSlug)/pullrequests"
        }
    }
}
