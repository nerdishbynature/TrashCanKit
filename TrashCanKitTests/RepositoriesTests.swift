import XCTest
import Nocilla
import TrashCanKit

class RepositoriesTests: XCTestCase {
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
        let repository = BitbucketRepository(json: TestHelper.loadJSON("Repository"))
        XCTAssertEqual(repository.id, "{cb706a3e-1e13-41fb-ac9d-e53e8adc2bd7}")
        XCTAssertEqual(repository.owner.login, "pietbrauer")
        XCTAssertEqual(repository.name, "octokit.swift")
        XCTAssertEqual(repository.fullName, "pietbrauer/octokit.swift")
        XCTAssertEqual(repository.isPrivate, true)
        XCTAssertEqual(repository.repositoryDescription, "Dummy Description")
        XCTAssertEqual(repository.sshURL, "git@bitbucket.org/pietbrauer/octokit.swift.git")
        XCTAssertEqual(repository.gitURL, "git://bitbucket.org/pietbrauer/octokit.swift.git")
        XCTAssertEqual(repository.cloneURL, "https://bitbucket.org/pietbrauer/octokit.swift.git")
        XCTAssertEqual(repository.size, 156382)
    }

    func testFailToConstructFromJSON() {
        let repository = BitbucketRepository(json: [:])
        XCTAssertEqual(repository.id, "-1")
        XCTAssertEqual(repository.isPrivate, false)
        XCTAssertEqual(repository.size, 0)
    }

    func testGetRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/repositories/bitbucketCat?access_token=123456").andReturn(200).withBody(TestHelper.loadJSONString("Repositories"))
        let expectation = expectationWithDescription("get_repos")
        TrashCanKit(tokenConfig).repositories("bitbucketCat") { response in
            switch response {
            case .Success(let repos):
                XCTAssertEqual(repos.count, 1)
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

    func testFailToGetRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        stubRequest("GET", "https://bitbucket.org/api/2.0/repositories/bitbucketCat?access_token=123456").andReturn(401).withBody(TestHelper.loadJSONString("refresh_token_error"))
        let expectation = expectationWithDescription("get_repos")
        TrashCanKit(tokenConfig).repositories("bitbucketCat") { response in
            switch response {
            case .Success:
                XCTAssertTrue(false)
                expectation.fulfill()
            case .Failure(let error):
                XCTAssertEqual((error as NSError).code, 401)
                XCTAssertEqual((error as NSError).domain, "com.octokit.swift")
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(1) { error in
            XCTAssertNil(error)
        }
    }
}
