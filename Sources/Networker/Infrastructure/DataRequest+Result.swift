//
//  DataRequest+Result.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire
import Combine

internal extension DataRequest {

    func result<T: Decodable>(
        type: T.Type = T.self,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods
    ) -> AnyPublisher<T, Error> {
        log()
            .validate()
            .publishDecodable(
                type: type,
                queue: queue,
                decoder: decoder,
                emptyResponseCodes: emptyResponseCodes,
                emptyRequestMethods: emptyResponseMethods
            )
            .map(mapToNetworkError)
            .flatMap(\.result.publisher)
            .eraseToAnyPublisher()
    }

    func asyncResult<T: Decodable>(
        type: T.Type = T.self,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<T>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<T>.defaultEmptyRequestMethods
    ) async -> Result<T, Error> {
        await withCheckedContinuation({ continuation in
            self.log()
                .validate()
                .responseDecodable(
                    of: T.self,
                    queue: queue,
                    decoder: decoder,
                    emptyResponseCodes: emptyResponseCodes,
                    emptyRequestMethods: emptyResponseMethods
                ) { [weak self] response in
                    continuation.resume(
                        returning: self?.toResultWithAppError(response: response) ?? response.result.mapError { $0 as Error }
                    )
                }
        })
    }

    private func toResultWithAppError<T: Decodable>(response: AFDataResponse<T>) -> Result<T, Error> {
        if !hasInternetConnection() {
            return .failure(NetworkerError.noInternet)
        }

        switch response.result {
        case .success(let data):
            return .success(data)

        case .failure(let error):
            return .failure(NetworkerError.afError(error, response.data))
        }
    }

    private func mapToNetworkError<T: Decodable>(_ response: DataResponse<T, AFError>) -> DataResponse<T, Error> {
        let result = response.result.mapError { afError -> Error in
            if hasInternetConnection() {
                return NetworkerError.afError(afError, response.data)
            }
            return NetworkerError.noInternet
        }

        let dataResponse = DataResponse(
            request: response.request,
            response: response.response,
            data: response.data,
            metrics: response.metrics,
            serializationDuration: response.serializationDuration,
            result: result
        )

        return dataResponse
    }

    private func hasInternetConnection() -> Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }
}
