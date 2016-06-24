import RequestKit

public struct TokenConfiguration: Configuration {
    public var apiEndpoint: String
    public var accessToken: String?
    public var refreshToken: String?
    public var expirationDate: Date?
    public let errorDomain = TrashCanKitErrorDomain

    public init(json: [String: AnyObject], url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = json["access_token"] as? String
        refreshToken = json["refresh_token"] as? String
        let expiresIn = json["expires_in"] as? Int
        let currentDate = Date()
        expirationDate = currentDate.addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }

    public init(_ token: String? = nil, refreshToken: String? = nil, expirationDate: Date? = nil, url: String = bitbucketBaseURL) {
        apiEndpoint = url
        accessToken = token
        self.expirationDate = expirationDate
        self.refreshToken = refreshToken
    }
}
