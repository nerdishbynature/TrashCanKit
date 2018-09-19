import Foundation
import RequestKit

public let BitbucketBaseURL = "https://bitbucket.org/api/2.0/"
public let BitbucketWebURL = "https://bitbucket.org/"
public let TrashCanKitErrorDomain = "com.nerdishbynature.TrashCanKit"

public struct TrashCanKit {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}

internal extension Router {
    internal var URLRequest: Foundation.URLRequest? {
        return request()
    }
}
