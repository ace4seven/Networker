//
//  File.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire
import Combine

public enum NetworkerConfiguration {
    public static var logLevel: ApiLogLevel = ApiLogLevel.info
}

public class Networker<T: EndpointType> {

    private let session: Session

    public init(
        configuration: URLSessionConfiguration = .default,
        interceptor: RequestInterceptor? = nil,
        serverTrustManager: ServerTrustManager? = nil
    ) {
        session = Session(
            configuration: configuration,
            interceptor: interceptor,
            serverTrustManager: serverTrustManager
        )
    }

    public func call<R: Decodable>(
        endpoint: T,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<R>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<R>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<R>.defaultEmptyRequestMethods
    ) -> AnyPublisher<R, Error> {
        do {
            return try request(endpoint: endpoint)
                .result(
                    queue: queue,
                    decoder: decoder,
                    preprocessor: preprocessor,
                    emptyResponseCodes: emptyResponseCodes,
                    emptyResponseMethods: emptyResponseMethods
                )
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        } catch let error {
            return Fail(error: AFError.createURLRequestFailed(error: error))
                .eraseToAnyPublisher()
        }
    }

    public func call<R: Decodable>(
        endpoint: T,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<R>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<R>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<R>.defaultEmptyRequestMethods
    ) async -> Result<R, Error> {
        do {
            return try await request(endpoint: endpoint)
                .asyncResult(
                    queue: queue,
                    decoder: decoder,
                    preprocessor: preprocessor,
                    emptyResponseCodes: emptyResponseCodes,
                    emptyResponseMethods: emptyResponseMethods
                )
                .mapError { $0 as Error }
        } catch let error {
            return .failure(error)
        }
    }

    public func cancelAllRequest() -> AnyPublisher<Void, Never> {
        Future { [weak self] seal in
            self?.session.cancelAllRequests(completion: {
                seal(.success(()))
            })
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Private

extension Networker {

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
