import XCTest
import TrashCanKit

class UserTests: XCTestCase {
    func testConstructFromJSON() {
        let subject = TestHelper.codableFromFile("User", type: User.self)
        XCTAssertEqual(subject.id, "{e9f0168c-cdf8-404a-95bb-3943dd2a65b6}")
        XCTAssertEqual(subject.login, "pietbrauer")
        XCTAssertEqual(subject.name, "Piet Brauer")
    }

    func testConstructEmailFromJSON() {
        let subject = TestHelper.codableFromFile("Email", type: Email.self)
        XCTAssertEqual(subject.isPrimary, true)
        XCTAssertEqual(subject.isConfirmed, true)
        XCTAssertEqual(subject.email, "me@supercooldomain.io")
        XCTAssertEqual(subject.type, "email")
    }

    func testMe() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/user?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "Me", statusCode: 200)
        let task = TrashCanKit(tokenConfig).me(session) { response in
            switch response {
            case .success(let user):
                XCTAssertEqual(user.name, "tutorials account")
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testMyEmail() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/user/emails?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "Emails", statusCode: 200)
        let task = TrashCanKit(tokenConfig).emails(session) { response in
            switch response {
            case .success(let emails):
                XCTAssertEqual(emails.first?.email, "tutorials@bitbucket.org")
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
}
