import Foundation
import RequestKit

// MARK: request

public extension TrashCanKit {
    public func refreshToken(_ session: RequestKitURLSession, oauthConfig: OAuthConfiguration, refreshToken: String, completion: @escaping (_ response: Response<TokenConfiguration>) -> Void) -> URLSessionDataTaskProtocol? {
        let request = TokenRouter.refreshToken(oauthConfig, refreshToken).URLRequest
        var task: URLSessionDataTaskProtocol?
        if let request = request {
            task = session.dataTask(with: request) { data, response, err in
                guard let response = response as? HTTPURLResponse else { return }
                guard let data = data else { return }
                do {
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let responseJSON = responseJSON as? [String: AnyObject] {
                        if response.statusCode != 200 {
                            let errorDescription = responseJSON["error_description"] as? String ?? ""
                            let error = NSError(domain: TrashCanKitErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                            completion(Response.failure(error))
                        } else {
                            let tokenConfig = TokenConfiguration(json: responseJSON)
                            completion(Response.success(tokenConfig))
                        }
                    }
                }
            }
            task?.resume()
        }
        return task
    }
}

public enum TokenRouter: Router {
    case refreshToken(OAuthConfiguration, String)

    public var configuration: Configuration {
        switch self {
        case .refreshToken(let config, _): return config
        }
    }

    public var method: HTTPMethod {
        return .POST
    }

    public var encoding: HTTPEncoding {
        return .form
    }

    public var params: [String: Any] {
        switch self {
        case .refreshToken(_, let token):
            return ["refresh_token": token, "grant_type": "refresh_token"]
        }
    }

    public var path: String {
        switch self {
        case .refreshToken(_, _):
            return "site/oauth2/access_token"
        }
    }

    public var URLRequest: Foundation.URLRequest? {
        switch self {
        case .refreshToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
