import Foundation
import RequestKit

let bitbucketBaseURL = "https://bitbucket.org/api/2.0"
let bitbucketWebURL = "https://bitbucket.org"
let BitbucketErrorDomain = "https://bitbucket.org"

public struct TrashCanKit {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}
