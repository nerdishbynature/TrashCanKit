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
}
