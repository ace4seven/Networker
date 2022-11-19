//
//  NetworkerTests.swift
//  
//
//  Created by Juraj Macák on 19/11/2022.
//

import XCTest
import Alamofire

@testable import Networker

final class NetworkerTests: XCTestCase {

    private var networker: Networker<TestEndpoint>!
    private let request = EncodableRequest(id: 121, name: "Lorem Ipsum Dolor", isValid: true)

    override func setUpWithError() throws {
        networker = Networker()
    }
}

extension NetworkerTests {

    func testNetworker_shouldSetURLParamenterEncodingOnGetType() {
        // Arrange
        let endpoint = TestEndpoint.testGet(request)
        let expectedStringURL = "https://www.test.com/api/v0/test?id=121&isValid=1&name=Lorem%20Ipsum%20Dolor"
        let bodyData = networker.bodyData(endpoint)
        var requestUrl = try! networker.requestUrl(endpoint)
        networker.setUrlWithComponents(for: &requestUrl, endpoint: endpoint)
        // Assert
        print(requestUrl.absoluteString)
        XCTAssertEqual(requestUrl.absoluteString, expectedStringURL)
        XCTAssertTrue(bodyData.isEmpty)
    }

    func testNetworker_shouldSetBodyParameterEncodingOnPostType() {
        // Arrange
        let endpoint = TestEndpoint.testPost(request)
        let expectedStringURL = "https://www.test.com/api/v0/test"
        let jsonDecoder = JSONDecoder()
        // Act
        let bodyData = networker.bodyData(endpoint)
        let decodedObject = try! jsonDecoder
            .decode(EncodableRequest.self, from: try! JSONSerialization.data(withJSONObject:bodyData))
        var requestUrl = try! networker.requestUrl(endpoint)
        networker.setUrlWithComponents(for: &requestUrl, endpoint: endpoint)
        // Assert
        XCTAssertEqual(requestUrl.absoluteString, expectedStringURL)
        XCTAssertEqual(decodedObject, request)
    }
}

private struct EncodableRequest: Codable, Equatable {

    let id: Int
    let name: String
    let isValid: Bool
}

private enum TestEndpoint: EndpointType {

    case testGet(EncodableRequest)
    case testPost(EncodableRequest)

    var path: String {
        return "test"
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .testGet:
            return .get

        case .testPost:
            return .post
        }
    }

    var parameters: Encodable? {
        switch self {
        case .testGet(let encodableRequest):
            return encodableRequest

        case .testPost(let encodableRequest):
            return encodableRequest
        }
    }

    var headers: Alamofire.HTTPHeaders? {
        return nil
    }

    func baseUrl() throws -> URL {
        try "https://www.test.com/api/v0/".asURL()
    }
}
