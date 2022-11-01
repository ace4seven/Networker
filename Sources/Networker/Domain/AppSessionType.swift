//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Combine
import Alamofire

protocol AppSessionType {

    associatedtype T: EndpointType
    associatedtype R: Decodable

    func call(
        endpoint: T,
        queue: DispatchQueue,
        decoder: JSONDecoder,
        preprocessor: DataPreprocessor,
        emptyResponseCodes: Set<Int>,
        emptyResponseMethods: Set<HTTPMethod>
    ) -> AnyPublisher<R, AFError>
}
