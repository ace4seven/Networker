//
//  Publisher+MapToResult.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Combine

internal extension Publisher {

    func mapToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
        map(Result.success)
            .catch { Just(.failure($0)) }
            .eraseToAnyPublisher()
    }
}
