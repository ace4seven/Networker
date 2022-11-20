//
//  NetworkerError.swift
//  
//
//  Created by Juraj Macák on 07/11/2022.
//

import Alamofire
import Foundation

public enum NetworkerError: Error {

    case afError(AFError, Data?)
    case noInternet
}
