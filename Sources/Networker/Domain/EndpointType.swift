//
//  EndpointType.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire

/// Use for declare Endpoint skeleton
public protocol EndpointType {

    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Encodable? { get }
    var parameters: Encodable? { get }
    var headers: HTTPHeaders? { get }

    func baseUrl() throws -> URL
}
