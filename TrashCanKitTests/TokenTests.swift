import XCTest
import TrashCanKit
import RequestKit

class TokenTests: XCTestCase {
    func testRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let kit = TrashCanKit(tokenConfig)
        let session = RefreshTokenMockSession()
        let task = kit.refreshToken(session, oauthConfig: oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .success(let newToken):
                XCTAssertEqual(newToken.accessToken, "017ec60f4a182")
                XCTAssertNotNil(newToken.expirationDate)
                XCTAssertEqual(newToken.refreshToken, "14567")
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testFailGettingRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/site/oauth2/access_token", expectedHTTPMethod: "POST", jsonFile: "refresh_token_error", statusCode: 401)
        let task = TrashCanKit(tokenConfig).refreshToken(session, oauthConfig: oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .success:
                XCTAssertFalse(true)
            case .failure(let error as NSError):
                XCTAssertEqual(error.domain, TrashCanKitErrorDomain)
                XCTAssertEqual(error.code, 401)
                XCTAssertEqual(error.localizedDescription, "Oh Oh, another error.")
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
}

class RefreshTokenMockSession: RequestKitURLSession {
    var wasCalled = false

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded")
        XCTAssertEqual(request.url?.absoluteString, "https://bitbucket.org/site/oauth2/access_token")
        let body = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)
        XCTAssertEqual(body, "grant_type=refresh_token&refresh_token=54321")
        XCTAssertEqual(request.httpMethod, "POST")
        let data = TestHelper.loadJSONString("authorize").data(using: String.Encoding.utf8)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "http/1.1", headerFields: ["Content-Type": "application/json"])
        completionHandler(data, response, nil)
        wasCalled = true
        return MockURLSessionDataTask()
    }

    func uploadTask(with request: URLRequest, fromData bodyData: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        XCTFail()
        return MockURLSessionDataTask()
    }
}
