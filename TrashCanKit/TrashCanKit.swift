import Foundation
import RequestKit

let bitbucketBaseURL = "https://bitbucket.org/api/2.0"
let bitbucketWebURL = "https://bitbucket.org"
let BitbucketErrorDomain = "https://bitbucket.org"

public struct TokenConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public var refreshToken: String?

    public init(_ token: String? = nil, refreshToken: String? = nil, url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = token
        self.refreshToken = refreshToken
    }
}

public struct TrashCanKit {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}

public struct OAuthConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public let token: String
    public let secret: String
    public let scopes: [String]
    public let webEndpoint: String

    public init(_ url: String = bitbucketBaseURL, webURL: String = bitbucketWebURL,
        token: String, secret: String, scopes: [String]) {
            apiEndpoint = url
            webEndpoint = webURL
            self.token = token
            self.secret = secret
            self.scopes = []
    }

    public func authenticate() -> NSURL? {
        return OAuthRouter.Authorize(self).URLRequest?.URL
    }

    private func basicAuthenticationString() -> String {
        let clientIDSecretString = [token, secret].joinWithSeparator(":")
        let clientIDSecretData = clientIDSecretString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64 = clientIDSecretData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        return "Basic \(base64 ?? "")"
    }

    public func basicAuthSession() -> NSURLSession {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = ["Authorization" : basicAuthenticationString()]
        return NSURLSession(configuration: config)
    }

    public func authorize(code: String, completion: (config: TokenConfiguration) -> Void) {
        let request = OAuthRouter.AccessToken(self, code).URLRequest
        if let request = request {
            let task = basicAuthSession().dataTaskWithRequest(request) { data, response, err in
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let config = self.configFromData(data) {
                            completion(config: config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    private func configFromData(data: NSData?) -> TokenConfiguration? {
        guard let data = data else { return nil }
        do {
            guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else { return nil }
            let accessToken = json["access_token"] as? String
            let refreshToken = json["refresh_token"] as? String
            if let accessToken = accessToken, refreshToken = refreshToken {
                let config = TokenConfiguration(accessToken, refreshToken: refreshToken)
                return config
            }
        } catch {
            return nil
        }
        return nil
    }

    public func handleOpenURL(url: NSURL, completion: (config: TokenConfiguration) -> Void) {
        let params = url.URLParameters()
        if let code = params["code"] {
            authorize(code) { config in
                completion(config: config)
            }
        }
    }

    public func accessTokenFromResponse(response: String) -> String? {
        let accessTokenParam = response.componentsSeparatedByString("&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.componentsSeparatedByString("=").last
        }
        return nil
    }
}

private extension NSURL {
    func URLParameters() -> [String: String] {
        let stringParams = absoluteString.componentsSeparatedByString("?").last
        let params = stringParams?.componentsSeparatedByString("&")
        var returnParams: [String: String] = [:]
        if let params = params {
            for param in params {
                let keyValue = param.componentsSeparatedByString("=")
                if let key = keyValue.first, value = keyValue.last {
                    returnParams[key] = value
                }
            }
        }
        return returnParams
    }
}

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
