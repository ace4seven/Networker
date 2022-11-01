//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Combine
import Alamofire

public extension Publisher {

    func mapToApiResult() -> AnyPublisher<ApiResult<Output, Failure>, Never> {
        mapToResult()
            .map { result in
                switch result {
                case .success(let value):
                    return .loaded(value)

                case .failure(let error):
                    return .error(error)
                }
            }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
