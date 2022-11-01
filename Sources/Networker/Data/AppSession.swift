//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire
import Combine

internal class AppSession<T: EndpointType> {

    private let session: Session

    init(
        configuration: URLSessionConfiguration,
        interceptor: RequestInterceptor? = nil,
        serverTrustManager: ServerTrustManager? = nil
    ) {
        session = Session(
            configuration: configuration,
            interceptor: interceptor,
            serverTrustManager: serverTrustManager
        )
    }

    func call<R: Decodable>(
        endpoint: T,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<R>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<R>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<R>.defaultEmptyRequestMethods
    ) -> AnyPublisher<R, AFError> {
        do {
            return try request(endpoint: endpoint)
                .result(
                    queue: queue,
                    decoder: decoder,
                    preprocessor: preprocessor,
                    emptyResponseCodes: emptyResponseCodes,
                    emptyResponseMethods: emptyResponseMethods
                )
                .eraseToAnyPublisher()
        } catch let error {
            return Fail(error: AFError.createURLRequestFailed(error: error))
                .eraseToAnyPublisher()
        }
    }

    func cancelAllRequest() -> AnyPublisher<Void, Never> {
        Future { [weak self] seal in
            self?.session.cancelAllRequests(completion: {
                seal(.success(()))
            })
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private

extension AppSession {

    private func request(
        endpoint: T
    ) throws -> DataRequest {
        var requestUrl: URL = try requestUrl(endpoint)
        setUrlWithComponents(for: &requestUrl, endpoint: endpoint)
        return session.request(
            requestUrl,
            method: endpoint.method,
            parameters: bodyData(endpoint),
            encoding: encoding(endpoint: endpoint),
            headers: endpoint.headers
        )
    }

    private func encoding(endpoint: T) -> ParameterEncoding {
        switch endpoint.method {
        case .get: return URLEncoding(destination: .methodDependent)
        default: return JSONEncoding.default
        }
    }

    private func requestUrl(_ endpoint: T) throws -> URL {
        do {
            return try endpoint
                .provider
                .baseUrl()
                .appendingPathComponent(endpoint.path)

        } catch let error {
            throw AFError.createURLRequestFailed(error: error)
        }
    }

    private func setUrlWithComponents(for requestUrl: inout URL, endpoint: T) {
        let urlComponent = NSURLComponents(
            url: requestUrl,
            resolvingAgainstBaseURL: false
        )

        urlComponent?.queryItems = endpoint.queryParameters?.jsonDictionary?.compactMap { key, value in

            return URLQueryItem(
                name: String(describing: key),
                value: String(describing: value)
            )
        }

        if let url = urlComponent?.url {
            requestUrl = url
        }

    }

    private func bodyData(_ endpoint: T) -> [String: Any] {
        var bodyData: [String: Any] = [:]
        bodyData = endpoint.parameters?.jsonDictionary ?? [:]
        return bodyData
    }
}
