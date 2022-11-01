//
//  Encodable+JsonDictionary.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation

internal extension Encodable {

    var jsonDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }

        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
