import RequestKit

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
