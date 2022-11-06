//
//  MockTests.swift
//  
//
//  Created by Juraj Macák on 06/11/2022.
//

import XCTest
import Combine
import Alamofire

@testable import Networker

final class MockTests: XCTestCase {

    private let person = Person(id: 1, firstName: "John", lastName: "Doe")
    private let error = AFError.explicitlyCancelled
    private var networker: Networker<EndpointTest>!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        networker = Networker()
    }

    override func tearDownWithError() throws {
        cancellables.removeAll()
    }

    func testMockWithReturnSuccess() throws {
        // Arrange
        let delayExpectation = expectation(description: "Mock Delay")
        let timeout: Double = 1

        let call = networker.mock(
            type: .success(person),
            delay: timeout
        )

        var fetchedPerson: Person?
        var catchedError: Error?

        // Act
        call
            .mapToResult()
            .sink { result in
                switch result {
                case .success(let person):
                    fetchedPerson = person

                case .failure(let error):
                    catchedError = error
                }

                delayExpectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: timeout)

        // Assert
        XCTAssertEqual(fetchedPerson, person)
        XCTAssertNil(catchedError)
    }

    func testMockWithReturnError() throws {
        // Arrange
        let delayExpectation = expectation(description: "Mock Delay")
        let timeout: Double = 2

        let call: AnyPublisher<Person, Error> = networker.mock(
            type: .failure(error),
            delay: timeout
        )

        var fetchedPerson: Person?
        var catchedError: Error?

        // Act
        call
            .mapToResult()
            .sink { result in
                switch result {
                case .success(let person):
                    fetchedPerson = person

                case .failure(let error):
                    catchedError = error
                }

                delayExpectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: timeout)

        // Assert
        XCTAssertNil(fetchedPerson)
        XCTAssertNotNil(catchedError)
    }

    func testMockWithReturnSuccessAsync() async {
        // Arrange
        let timeout: UInt64 = 2

        let call: Result<Person, Error> = await networker.mock(
            type: .success(person),
            delay: timeout
        )

        var fetchedPerson: Person?
        var catchedError: Error?

        // Act
        switch call {
        case .success(let success):
            fetchedPerson = success

        case .failure(let failure):
            catchedError = failure
        }

        // Assert
        XCTAssertEqual(fetchedPerson, person)
        XCTAssertNil(catchedError)
    }

    func testMockWithReturnErrorAsync() async {
        // Arrange
        let timeout: UInt64 = 2

        let call: Result<Person, Error> = await networker.mock(
            type: .failure(error),
            delay: timeout
        )

        var fetchedPerson: Person?
        var catchedError: Error?

        // Act
        switch call {
        case .success(let success):
            fetchedPerson = success

        case .failure(let failure):
            catchedError = failure
        }

        // Assert
        XCTAssertNil(fetchedPerson)
        XCTAssertNotNil(catchedError)
    }
}
