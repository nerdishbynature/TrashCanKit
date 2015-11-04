import XCTest
import Nocilla
import TrashCanKit

class ConfigurationTests: XCTestCase {
    private let enterpriseURL = "https://enterprise.mybitbucketserver.com"

    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testTokenConfiguration() {
        let subject = TokenConfiguration("12345")
        XCTAssertEqual(subject.accessToken, "12345")
        XCTAssertEqual(subject.apiEndpoint, "https://bitbucket.org/api/2.0")
    }

    func testEnterpriseTokenConfiguration() {
        let subject = TokenConfiguration("12345", url: enterpriseURL)
        XCTAssertEqual(subject.accessToken!, "12345")
        XCTAssertEqual(subject.apiEndpoint, enterpriseURL)
    }

    func testOAuthConfiguration() {
        let subject = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        XCTAssertEqual(subject.token, "12345")
        XCTAssertEqual(subject.secret, "6789")
        XCTAssertEqual(subject.apiEndpoint, "https://bitbucket.org/api/2.0")
    }

    func testOAuthTokenConfiguration() {
        let subject = OAuthConfiguration(enterpriseURL, token: "12345", secret: "6789", scopes: [])
        XCTAssertEqual(subject.token, "12345")
        XCTAssertEqual(subject.secret, "6789")
        XCTAssertEqual(subject.apiEndpoint, enterpriseURL)
    }

    func testAuthorizeURLRequest() {
        let config = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        let request = OAuthRouter.Authorize(config).URLRequest
        let expected = NSURL(string: "https://bitbucket.org/site/oauth2/authorize?client_id=12345&response_type=code")
        XCTAssertEqual(request?.URL, expected)
    }

    func testAccessTokenURLRequest() {
        let config = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        let request = OAuthRouter.AccessToken(config, "dhfjgh23493").URLRequest
        let expected = NSURL(string: "https://bitbucket.org/site/oauth2/access_token")
        let expectedBody = "code=dhfjgh23493&grant_type=authorization_code"
        XCTAssertEqual(request?.URL, expected)
        let string = NSString(data: request!.HTTPBody!, encoding: NSUTF8StringEncoding)!
        XCTAssertEqual(string as String, expectedBody)
    }

    func testAccessTokenFromResponse() {
        let config = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        let response = "access_token=017ec60f4a182&token_type=bearer"
        let expectation = "017ec60f4a182"
        XCTAssertEqual(config.accessTokenFromResponse(response)!, expectation)
    }

    func testHandleOpenURL() {
        let config = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        let json = TestHelper.loadJSONString("authorize")
        let headers = ["Authorization": "Basic MTIzNDU6Njc4OQ==", "Content-Type": "application/x-www-form-urlencoded" ]
        stubRequest("POST", "https://bitbucket.org/site/oauth2/access_token").withHeaders(headers).andReturn(200).withBody(json)
        let expectation = expectationWithDescription("access_token")
        let url = NSURL(string: "urlscheme://authorize?code=dhfjgh23493")!
        config.handleOpenURL(url) { token in
            XCTAssertEqual(token.refreshToken, "14567")
            XCTAssertEqual(token.accessToken, "017ec60f4a182")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: { error in
            XCTAssertNil(error, "\(error)")
        })
    }
}
