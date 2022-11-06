//
//  File.swift
//  
//
//  Created by Juraj Macák on 06/11/2022.
//

import Alamofire
import Combine
import Foundation

internal enum MockTypeError: Error {
    case noError
}

public extension Networker {

    func mock<R: Decodable>(
        type: MockType<R>,
        delay: Double = .zero
    ) -> AnyPublisher<R, Error> {
        switch type {
        case .success(let r):
            return Just<R>(r)
                .mapError { _ in MockTypeError.noError }
                .delay(for: RunLoop.SchedulerTimeType.Stride(delay), scheduler: RunLoop.main)
                .eraseToAnyPublisher()

        case .failure(let error):
            return Fail(error: error)
                .delay(for: RunLoop.SchedulerTimeType.Stride(delay), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        }
    }

    @MainActor
    func mock<R: Decodable>(
        type: MockType<R>,
        delay: UInt64 = .zero
    ) async -> Result<R, Error> {
        try? await Task.sleep(nanoseconds: delay * 1_000_000_000)

        switch type {
        case .success(let r):
            return Result.success(r)
        case .failure(let error):
            return Result.failure(error)
        }
    }
}
