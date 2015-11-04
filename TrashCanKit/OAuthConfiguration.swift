import Foundation
import RequestKit

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
