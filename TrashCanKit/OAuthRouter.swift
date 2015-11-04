import RequestKit

public enum OAuthRouter: Router {
    case Authorize(OAuthConfiguration)
    case AccessToken(OAuthConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .Authorize(let config): return config
        case .AccessToken(let config, _): return config
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .Authorize:
            return .GET
        case .AccessToken:
            return .POST
        }
    }

    public var encoding: HTTPEncoding {
        switch self {
        case .Authorize:
            return .URL
        case .AccessToken:
            return .FORM
        }
    }

    public var path: String {
        switch self {
        case .Authorize:
            return "site/oauth2/authorize"
        case .AccessToken:
            return "site/oauth2/access_token"
        }
    }

    public var params: [String: String] {
        switch self {
        case .Authorize(let config):
            return ["client_id": config.token, "response_type": "code"]
        case .AccessToken(_, let code):
            return ["code": code, "grant_type": "authorization_code"]
        }
    }

    public var URLRequest: NSURLRequest? {
        switch self {
        case .Authorize(let config):
            let URLString = config.webEndpoint.stringByAppendingURLPath(path)
            return request(URLString, parameters: params)
        case .AccessToken(let config, _):
            let URLString = config.webEndpoint.stringByAppendingURLPath(path)
            return request(URLString, parameters: params)
        }
    }
}
