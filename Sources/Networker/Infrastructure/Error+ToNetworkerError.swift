//
//  File.swift
//  
//
//  Created by Juraj Macák on 07/11/2022.
//

import Foundation

public extension Error {

    var payloadData: Data? {
        if case .afError(_, let payload) = toNetworkerError() {
            return payload
        }

        return nil
    }

    func payload<T: Decodable>() -> T? {
        guard let payloadData else { return nil }

        return try? JSONDecoder().decode(T.self, from: payloadData)
    }

    func toNetworkerError() -> NetworkerError? {
        self as? NetworkerError
    }
}
