import XCTest
import Nocilla
import TrashCanKit

class PullRequestTests: XCTestCase {
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
        let repository = PullRequest(json: TestHelper.loadJSON("PullRequest"))
        XCTAssertEqual(repository.id, "3767")
        XCTAssertEqual(repository.author?.login, "mfrauenholtz")
        XCTAssertEqual(repository.pullRequestDescription, "![img](https://cloudup.com/c7ZJtChLw9J+)\r\n\r\n## Removing:\r\n\r\n* Notifications\r\n* Email\r\n* Change password\r\n* Sessions\r\n\r\n## Renaming: \r\n\r\n* Change username\r\n* Delete account (rename to delete team)\r\n\r\n")
        XCTAssertEqual(repository.state, "OPEN")
    }
    
    func testFailToConstructFromJSON() {
        let repository = PullRequest(json: [:])
        XCTAssertEqual(repository.id, "-1")
    }
    
    func testGetPullRequests() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/repositories/nerdishbynature/octokit.swift/pullrequests?access_token=123456").andReturn(200).withBody(TestHelper.loadJSONString("PullRequests"))
        let expectation = expectationWithDescription("get_pull_requests")
        TrashCanKit(tokenConfig).pullRequests("nerdishbynature", repoSlug: "octokit.swift") { response in
            switch response {
            case .Success(let pullRequests, let nextParameters):
                XCTAssertEqual(nextParameters["page"], "2")
                XCTAssertEqual(pullRequests.count, 1)
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

    func testGetPullRequestsWithError() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/repositories/nerdishbynature/octokit.swift/pullrequests?access_token=123456").andReturn(404)
        let expectation = expectationWithDescription("get_pull_requests")
        TrashCanKit(tokenConfig).pullRequests("nerdishbynature", repoSlug: "octokit.swift") { response in
            switch response {
            case .Success:
                XCTAssertTrue(false)
                expectation.fulfill()
            case .Failure(let error):
                XCTAssertEqual((error as NSError).code, 404)
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(1) { error in
            XCTAssertNil(error)
        }
    }
}
