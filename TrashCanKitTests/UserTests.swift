import XCTest
import Nocilla
import TrashCanKit

class UserTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }

    func testConstructFromJSON() {
        let subject = User(TestHelper.loadJSON("User"))
        XCTAssertEqual(subject.id, "{e9f0168c-cdf8-404a-95bb-3943dd2a65b6}")
        XCTAssertEqual(subject.login, "pietbrauer")
        XCTAssertEqual(subject.name, "Piet Brauer")
    }

    func testConstructEmailFromJSON() {
        let subject = Email(json: TestHelper.loadJSON("Email"))
        XCTAssertEqual(subject.isPrimary, true)
        XCTAssertEqual(subject.isConfirmed, true)
        XCTAssertEqual(subject.email, "me@supercooldomain.io")
        XCTAssertEqual(subject.type, "email")
    }

    func testConstructEmailFromEmptyJSON() {
        let subject = Email(json: [:])
        XCTAssertEqual(subject.isPrimary, false)
        XCTAssertEqual(subject.isConfirmed, false)
        XCTAssertEqual(subject.email, nil)
        XCTAssertEqual(subject.type, nil)
    }

    func testMe() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/user?access_token=123456").andReturn(200).withBody(TestHelper.loadJSONString("Me"))
        let expectation = expectationWithDescription("get_me")
        TrashCanKit(tokenConfig).me() { response in
            switch response {
            case .Success(let user):
                XCTAssertEqual(user.name, "tutorials account")
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

    func testMyEmail() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/user/emails?access_token=123456").andReturn(200).withBody(TestHelper.loadJSONString("Emails"))
        let expectation = expectationWithDescription("get_me")
        TrashCanKit(tokenConfig).emails() { response in
            switch response {
            case .Success(let emails):
                XCTAssertEqual(emails.first?.email, "tutorials@bitbucket.org")
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
