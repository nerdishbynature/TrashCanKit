import XCTest
import RequestKit
import TrashCanKit

class ConfigurationTests: XCTestCase {
    func testTokenConfiguration() {
        let subject = TokenConfiguration("12345")
        XCTAssertEqual(subject.accessToken, "12345")
        XCTAssertEqual(subject.apiEndpoint, "https://bitbucket.org/api/2.0")
    }

    func testOAuthConfiguration() {
        let subject = OAuthConfiguration(token: "12345", secret: "6789", scopes: [])
        XCTAssertEqual(subject.token, "12345")
        XCTAssertEqual(subject.secret, "6789")
        XCTAssertEqual(subject.apiEndpoint, "https://bitbucket.org/api/2.0")
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
        let session = BasicAuthMockSession()
        let url = NSURL(string: "urlscheme://authorize?code=dhfjgh23493")!
        var token: TokenConfiguration?
        config.handleOpenURL(session, url: url) { inToken in
            token = inToken
        }
        XCTAssertEqual(token?.refreshToken, "14567")
        XCTAssertEqual(token?.accessToken, "017ec60f4a182")
    }
}

class BasicAuthMockSession: RequestKitURLSession {
    var wasCalled = false

    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> URLSessionDataTaskProtocol {
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(request.URL?.absoluteString, "https://bitbucket.org/site/oauth2/access_token")
        XCTAssertEqual(request.HTTPMethod, "POST")
        let data = TestHelper.loadJSONString("authorize").dataUsingEncoding(NSUTF8StringEncoding)
        let response = NSHTTPURLResponse(URL: request.URL!, statusCode: 200, HTTPVersion: "http/1.1", headerFields: ["Content-Type": "application/json"])
        completionHandler(data, response, nil)
        wasCalled = true
        return MockURLSessionDataTask()
    }

    func uploadTaskWithRequest(request: NSURLRequest, fromData bodyData: NSData?, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> URLSessionDataTaskProtocol {
        XCTFail()
        return MockURLSessionDataTask()
    }
}
