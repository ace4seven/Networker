//
//  File.swift
//  
//
//  Created by Juraj Macák on 07/11/2022.
//

import Foundation

public extension Error {

    var payloadData: Data? {
        toNetworkerError()?.payloadData
    }

    func toNetworkerError() -> NetworkerError? {
        self as? NetworkerError
    }
}
