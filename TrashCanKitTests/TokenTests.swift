import XCTest
import Nocilla
import TrashCanKit

class TokenTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let kit = TrashCanKit(tokenConfig)
        let expectation = expectationWithDescription("refreshToken")
        stubRequest("POST", "https://bitbucket.org/site/oauth2/access_token").withHeaders([ "Authorization": "Basic MTIzNDU6Njc4OTA=", "Content-Type": "application/x-www-form-urlencoded" ]).withBody("grant_type=refresh_token&refresh_token=54321").andReturn(200).withBody(TestHelper.loadJSONString("authorize"))
        kit.refreshToken(oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .Success(let newToken):
                XCTAssertEqual(newToken, "017ec60f4a182")
                expectation.fulfill()
            case .Failure:
                XCTAssertFalse(true)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(1) { error in
            XCTAssertNil(error)
        }
    }

    func testFailGettingRefreshToken() {
        let oauthConfig = OAuthConfiguration(token: "12345", secret: "67890", scopes: [])
        let tokenConfig = TokenConfiguration("09876", refreshToken: "54321")
        let kit = TrashCanKit(tokenConfig)
        let expectation = expectationWithDescription("refreshToken")
        stubRequest("POST", "https://bitbucket.org/site/oauth2/access_token").withHeaders([ "Authorization": "Basic MTIzNDU6Njc4OTA=", "Content-Type": "application/x-www-form-urlencoded" ]).withBody("grant_type=refresh_token&refresh_token=54321").andReturn(401).withBody(TestHelper.loadJSONString("refresh_token_error"))
        kit.refreshToken(oauthConfig, refreshToken: tokenConfig.refreshToken!) { response in
            switch response {
            case .Success:
                XCTAssertFalse(true)
                expectation.fulfill()
            case .Failure(let error as NSError):
                XCTAssertEqual(error.domain, "com.nerdishbynature.bitbucket.error")
                XCTAssertEqual(error.code, 401)
                XCTAssertEqual(error.localizedDescription, "Oh Oh, another error.")
                expectation.fulfill()
            case .Failure:
                XCTAssertFalse(true)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(1) { error in
            XCTAssertNil(error)
        }
    }
}
