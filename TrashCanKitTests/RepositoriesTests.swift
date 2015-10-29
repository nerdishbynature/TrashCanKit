import XCTest
import TrashCanKit

class RepositoriesTests: XCTestCase {
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
}
