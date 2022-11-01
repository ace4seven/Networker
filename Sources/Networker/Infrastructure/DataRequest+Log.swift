//
//  DataRequest+Log.swift
//  
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation
import Alamofire

/// Log level enum
///
/// error - prints only when error occurs
/// info - prints request url with response status and error when occurs
/// verbose - prints everything including request body and response object
public enum ApiLogLevel {
    case error, info, verbose
}

/// Functions for printing in each log level.
private func logError(_ text: String) {
#if DEBUG
    print(text)
#endif
}

private func logInfo(_ text: String) {
#if DEBUG
    if NetworkerConfiguration.logLevel != .error {
        print(text)
    }
#endif
}

private func logVerbose(_ text: String) {
#if DEBUG
    if NetworkerConfiguration.logLevel == .verbose {
        print(text)
    }
#endif
}

internal extension DataRequest {

    func log() -> Self {
        response { response in
            print("")

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss / dd.MM.yyyy"
            let dateTimeString = formatter.string(from: Date())

            if let request = response.request {
                if let url = request.url?.absoluteString.removingPercentEncoding,
                   let method = response.request?.httpMethod {
                    if response.error == nil {
                        logInfo("🚀 \(method) \(url)\n⏳ \(dateTimeString)")
                    } else {
                        logError("🚀 \(method) \(url)\n⏳ \(dateTimeString)")
                    }
                }

                if let body = request.httpBody,
                   let string = String(data: body, encoding: String.Encoding.utf8),
                   string.count > 0 {
                    logVerbose("📦 \(string)")
                }
            }

            if let response = response.response {
                switch response.statusCode {
                case 200 ..< 300:
                    logInfo("✅ \(response.statusCode)")
                default:
                    logInfo("❌ \(response.statusCode)")
                }
            }

            if let data = response.data,
               let string = String(data: data, encoding: String.Encoding.utf8),
               string.count > 0 {
                logVerbose("📦 \(string)")
            }

            if let error = response.error as NSError? {
                logError("‼️ [\(error.domain) \(error.code)] \(error.localizedDescription)")
            } else if let error = response.error {
                logError("‼️ \(error)")
            }
        }

        return self
    }
}
