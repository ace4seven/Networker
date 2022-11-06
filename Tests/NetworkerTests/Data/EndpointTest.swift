//
//  File.swift
//  
//
//  Created by Juraj Macák on 06/11/2022.
//

import Foundation
import Alamofire
@testable import Networker

struct Person: Decodable, Equatable {

    let id: Int
    let firstName: String
    let lastName: String
}

enum EndpointTest: EndpointType {

    case persons

    var path: String { "" }

    var method: Alamofire.HTTPMethod { .get }

    var queryParameters: Encodable? { nil }

    var parameters: Encodable? { nil }

    var headers: Alamofire.HTTPHeaders? { nil }

    func baseUrl() throws -> URL { try "".asURL() }
}
