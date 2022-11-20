//
//  NetworkerErrorTest.swift
//  
//
//  Created by Juraj Macák on 20/11/2022.
//

import XCTest
import Alamofire

@testable import Networker

final class NetworkerErrorTest: XCTestCase {

    private var networker: Networker<EndpointTest>!
    private var jsonEncoder: JSONEncoder!

    override func setUpWithError() throws {
        networker = Networker()
        jsonEncoder = JSONEncoder()
    }
}

extension NetworkerErrorTest {

    func testNetworkerError_shouldConvertIntoProvidedErrorPayload() {
        // Arrange
        let codablePayload = CodableErrorPayload(title: "Error Title", description: "Error Description")
        let payloadData = try! jsonEncoder.encode(codablePayload)
        // Act
        let error = NetworkerError.afError(AFError.explicitlyCancelled, payloadData)
        let payload: CodableErrorPayload? = error.payload()
        // Assert
        XCTAssertEqual(payload, codablePayload)
    }
}

private struct CodableErrorPayload: Codable, Equatable {

    let title: String
    let description: String
}
