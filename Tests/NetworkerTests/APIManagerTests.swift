import XCTest
import Combine
import Alamofire

@testable import Networker

final class APIManagerTests: XCTestCase {

    private var manager: Networker<Endpoint> = Networker()
    private var cancellables = Set<AnyCancellable>()

    func testGetResultAnyPublisher() throws {
        let expectation = self.expectation(description: "GET")
        var error: Error?

        getData()
            .mapToResult()
            .sink { result in
                switch result {
                case .failure(let afError):
                    error = afError

                case .success(let dto):
                    print(dto)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
        XCTAssertNil(error)
    }

    func testGetApiResultPublisher() throws {
        let expectation = self.expectation(description: "GET")

        var error: Error?
        var dto: PlanetsDto?
        var loadingActive: Bool = false

        getDataAsApiResult()
            .sink { result in
                switch result {
                case .loading:
                    loadingActive = true

                case .error(let afError):
                    error = afError

                case .loaded(let data):
                    dto = data
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 10)
        XCTAssertNil(error)
        XCTAssertNotNil(dto)
        XCTAssertTrue(loadingActive)
    }
}

// MARK: - API Calls

extension APIManagerTests {

    func getData() -> AnyPublisher<PlanetsDto, AFError> {
        manager
            .call(endpoint: .planets)
    }

    func getDataAsApiResult() -> AnyPublisher<ApiResult<PlanetsDto, AFError>, Never> {
        manager
            .call(endpoint: .planets)
            .mapToApiResult()
    }
}
