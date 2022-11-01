//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire
import Combine

internal extension DataRequest {

    func result<T: Decodable>(
        type: T.Type = T.self,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods
    ) -> AnyPublisher<T, AFError> {
        log()
            .validate()
            .publishDecodable(
                type: type,
                queue: queue,
                decoder: decoder,
                emptyResponseCodes: emptyResponseCodes,
                emptyRequestMethods: emptyResponseMethods
            )
            .flatMap(\.result.publisher)
            .eraseToAnyPublisher()
    }
}
