import Alamofire
import Foundation
import Combine

public final class Networker<T: EndpointType> {

    private let session: AppSession<T>

    public init(
        configuration: URLSessionConfiguration = .default,
        interceptor: RequestInterceptor? = nil,
        serverTrustManager: ServerTrustManager? = nil
    ) {
        session = AppSession(
            configuration: configuration,
            interceptor: interceptor,
            serverTrustManager: serverTrustManager
        )
    }
}

public enum NetworkerConfiguration {

    static var logLevel: ApiLogLevel = ApiLogLevel.info
}

// MARK: - Public

public extension Networker {

    func call<R: Decodable>(
        endpoint: T,
        queue: DispatchQueue = .main,
        decoder: JSONDecoder = JSONDecoder(),
        preprocessor: DataPreprocessor = DecodableResponseSerializer<R>.defaultDataPreprocessor,
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer<R>.defaultEmptyResponseCodes,
        emptyResponseMethods: Set<HTTPMethod> = DecodableResponseSerializer<R>.defaultEmptyRequestMethods
    ) -> AnyPublisher<R, AFError> {
        session.call(
            endpoint: endpoint,
            decoder: decoder,
            preprocessor: preprocessor,
            emptyResponseCodes: emptyResponseCodes,
            emptyResponseMethods: emptyResponseMethods
        )
    }
}
