//
//  MockType.swift
//  
//
//  Created by Juraj Macák on 06/11/2022.
//

import Foundation

public enum MockType<R: Decodable> {
    
    case success(R)
    case failure(Error)
}
