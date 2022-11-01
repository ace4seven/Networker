//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire
@testable import Networker

enum Provider: ProviderType {
    case swapi

    func baseUrl() throws -> URL {
        switch self {
        case .swapi: return try "https://swapi.dev/api/".asURL()
        }
    }
}

enum Endpoint: EndpointType {

    case planets

    var provider: ProviderType {
        Provider.swapi
    }

    var path: String {
        switch self {
        case .planets: return "planets/"
        }
    }

    var method: Alamofire.HTTPMethod {
        .get
    }

    var queryParameters: Encodable? {
        nil
    }

    var parameters: Encodable? {
        nil
    }

    var headers: Alamofire.HTTPHeaders? {
        nil
    }
}
