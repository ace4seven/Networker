//
//  ApiResult.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation

public enum ApiResult<T, E: Error> {

    case created
    case loading
    case loaded(T)
    case error(E)
}

public extension ApiResult {

    var isCreated: Bool {
        if case .created = self {
            return true
        }

        return false
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

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
