//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation

import Foundation

public enum ApiResult<T, E: Error> {

    case loading
    case loaded(T)
    case error(E)
}

public extension ApiResult {

    var data: T? {
        if case .loaded(let wrappedData) = self {
            return wrappedData
        }

        return nil
    }

    var error: E? {
        if case .error(let error) = self {
            return error
        }

        return nil
    }
}
