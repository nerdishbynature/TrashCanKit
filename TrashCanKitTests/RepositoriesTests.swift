import XCTest
import TrashCanKit

class RepositoriesTests: XCTestCase {
    func testConstructFromJSON() {
        let repository = TestHelper.codableFromFile("Repository", type: Repository.self)
        XCTAssertEqual(repository.id, "{cb706a3e-1e13-41fb-ac9d-e53e8adc2bd7}")
        XCTAssertEqual(repository.owner.login, "pietbrauer")
        XCTAssertEqual(repository.name, "octokit.swift")
        XCTAssertEqual(repository.fullName, "pietbrauer/octokit.swift")
        XCTAssertEqual(repository.isPrivate, true)
        XCTAssertEqual(repository.repositoryDescription, "Dummy Description")
        XCTAssertEqual(repository.links?.clone?.first?.href?.absoluteString, "https://pietbrauer@bitbucket.org/pietbrauer/octokit.swift.git")
        XCTAssertEqual(repository.links?.clone?.first?.name, "https")
        XCTAssertEqual(repository.links?.clone?.last?.href?.absoluteString, "ssh://git@bitbucket.org/pietbrauer/octokit.swift.git")
        XCTAssertEqual(repository.links?.clone?.last?.name, "ssh")
        XCTAssertEqual(repository.size, 156382)
        XCTAssertEqual(repository.scm, "git")
    }

    func testGetRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories?access_token=123456&role=member", expectedHTTPMethod: "GET", jsonFile: "Repositories", statusCode: 200)
        let task = TrashCanKit(tokenConfig).repositories(session) { response in
            switch response {
            case .success(let repos, let nextParameters):
                XCTAssertEqual(nextParameters["access_token"], "123456==")
                XCTAssertEqual(nextParameters["after"], "2015-11-06T03:45:07.833168+00:00")
                XCTAssertEqual(nextParameters["role"], "member")
                XCTAssertEqual(nextParameters["page"], "2")
                XCTAssertEqual(repos.count, 10)
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testGetUserRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories/bitbucketCat?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "Repositories", statusCode: 200)
        let task = TrashCanKit(tokenConfig).repositories(session, userName: "bitbucketCat") { response in
            switch response {
            case .success(let repos, _):
                XCTAssertEqual(repos.count, 10)
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testGetSecondPageRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories?access_token=123456&after=2015-11-06T03%3A45%3A07.833168%2B00%3A00&page=2&role=member", expectedHTTPMethod: "GET", jsonFile: "Repositories", statusCode: 200)
        let nextParameters = ["access_token": "123456==", "after": "2015-11-06T03:45:07.833168+00:00", "role": "member", "page": "2"]
        let task = TrashCanKit(tokenConfig).repositories(session, nextParameters: nextParameters) { response in
            switch response {
            case .success(let repos, _):
                XCTAssertEqual(repos.count, 10)
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testFailToGetRepositories() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories/bitbucketCat?access_token=123456", expectedHTTPMethod: "GET", jsonFile: "refresh_token_error", statusCode: 401)
        let task = TrashCanKit(tokenConfig).repositories(session, userName: "bitbucketCat") { response in
            switch response {
            case .success:
                XCTAssertTrue(false)
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 401)
                XCTAssertEqual((error as NSError).domain, TrashCanKitErrorDomain)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testGetRepository() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories/pietbrauer/octokit.swift?access_token=123456", expectedHTTPMethod: "GET", jsonFile: nil, statusCode: 200)
        let task = TrashCanKit(tokenConfig).repository(session, owner: "pietbrauer", name: "octokit.swift") { response in
            switch response {
            case .success(let repo):
                XCTAssertEqual(repo.name, "octokit.swift")
            case .failure:
                XCTAssertFalse(true)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }

    func testFailToGetRepository() {
        let tokenConfig = TokenConfiguration("123456", refreshToken: "7890")
        let session = TrashCanKitURLTestSession(expectedURL: "https://bitbucket.org/api/2.0/repositories/pietbrauer/octokit.swift?access_token=123456", expectedHTTPMethod: "GET", jsonFile: nil, statusCode: 401)
        let task = TrashCanKit(tokenConfig).repository(session, owner: "pietbrauer", name: "octokit.swift") { response in
            switch response {
            case .success:
                XCTAssertTrue(false)
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 401)
                XCTAssertEqual((error as NSError).domain, TrashCanKitErrorDomain)
            }
        }
        XCTAssertNotNil(task)
        XCTAssertTrue(session.wasCalled)
    }
}
