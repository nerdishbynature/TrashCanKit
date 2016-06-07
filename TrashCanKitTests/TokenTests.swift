import XCTest
import TrashCanKit
import RequestKit

class TokenTests: XCTestCase {
    func testRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let kit = TrashCanKit(tokenConfig)
        let session = RefreshTokenMockSession()
        kit.refreshToken(session, oauthConfig: oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .Success(let newToken):
                XCTAssertEqual(newToken.accessToken, "017ec60f4a182")
                XCTAssertNotNil(newToken.expirationDate)
                XCTAssertEqual(newToken.refreshToken, "14567")
            case .Failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }

    func testFailGettingRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/site/oauth2/access_token", expectedHTTPMethod: "POST", jsonFile: "refresh_token_error", statusCode: 401)
        TrashCanKit(tokenConfig).refreshToken(session, oauthConfig: oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .Success:
                XCTAssertFalse(true)
            case .Failure(let error as NSError):
                XCTAssertEqual(error.domain, TrashCanKitErrorDomain)
                XCTAssertEqual(error.code, 401)
                XCTAssertEqual(error.localizedDescription, "Oh Oh, another error.")
            case .Failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }
}

class RefreshTokenMockSession: RequestKitURLSession {
    var wasCalled = false

    func dataTaskWithRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> URLSessionDataTaskProtocol {
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(request.URL?.absoluteString, "https://bitbucket.org/site/oauth2/access_token")
        let body = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(body, "grant_type=refresh_token&refresh_token=54321")
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
