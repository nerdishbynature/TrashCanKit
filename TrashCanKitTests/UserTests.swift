import XCTest
import TrashCanKit

class UserTests: XCTestCase {
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
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/user?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "Me", statusCode: 200)
        TrashCanKit(tokenConfig).me(session) { response in
            switch response {
            case .Success(let user):
                XCTAssertEqual(user.name, "tutorials account")
            case .Failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }

    func testMyEmail() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/user/emails?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "Emails", statusCode: 200)
        TrashCanKit(tokenConfig).emails(session) { response in
            switch response {
            case .Success(let emails):
                XCTAssertEqual(emails.first?.email, "tutorials@bitbucket.org")
            case .Failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertTrue(session.wasCalled)
    }
}
