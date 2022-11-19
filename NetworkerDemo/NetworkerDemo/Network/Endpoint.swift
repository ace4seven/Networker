//
//  Endpoint.swift
//  NetworkerDemo
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Networker
import Alamofire

enum Endpoint: EndpointType {

    case swapiPlanets
    case planetDetail(page: Int)

    var path: String {
        switch self {
        case .swapiPlanets: return "planets"
        case .planetDetail(page: let page): return "planets/\(page)"
        }
    }

    var method: Alamofire.HTTPMethod {
        .get
    }

    var parameters: Encodable? {
        nil
    }

    var headers: Alamofire.HTTPHeaders? {
        nil
    }

    func baseUrl() throws -> URL {
        try "https://swapi.dev/api/".asURL()
    }
}
