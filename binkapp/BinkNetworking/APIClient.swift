//
//  APIClient.swift
//  binkapp
//
//  Created by Nick Farrant on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

// MARK: - Config and init

final class APIClient {
    typealias APIClientCompletionHandler<ResponseType: Any> = (Result<ResponseType, NetworkingError>) -> Void

    struct Certificates {
        static let bink = Certificates.certificate(filename: "bink")

        private static func certificate(filename: String) -> SecCertificate {
            let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            let certificate = SecCertificateCreateWithData(nil, data as CFData)!

            return certificate
        }
    }

    enum NetworkStrength: String {
        case wifi
        case cellular
        case unknown
    }

    enum APIVersion: String {
        case v1_1 = "v=1.1"
        case v1_2 = "v=1.2"
    }

    var networkIsReachable: Bool {
        return reachabilityManager?.isReachable ?? false
    }

    var networkStrength: NetworkStrength {
        if reachabilityManager?.isReachableOnCellular == true {
            return .cellular
        }
        if reachabilityManager?.isReachableOnEthernetOrWiFi == true {
            return .wifi
        }
        return .unknown
    }

    var isProduction: Bool {
        return APIConstants.baseURLString == EnvironmentType.production.rawValue
    }

    var apiVersion: APIVersion = .v1_1

    private let successStatusRange = 200...299
    private let clientErrorStatusRange = 400...499
    private let unauthorizedStatus = 401
    private let badRequestStatus = 400
    private let serverErrorStatusRange = 500...599

    private let reachabilityManager = NetworkReachabilityManager()
    private let session: Session

    init() {
        let evaluators = [
            // TODO: this shouldn't be hardcoded here
            "api.gb.bink.com":
                PinnedCertificatesTrustEvaluator(certificates: [
                    Certificates.bink
                ])
        ]

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        session = Session(configuration: configuration, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: evaluators))
    }
}

// MARK: - Request handling

extension APIClient {
    func performRequest<ResponseType: Codable>(onEndpoint endpoint: APIEndpoint, using method: HTTPMethod, headers: [String: String]? = nil, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {

        if !networkIsReachable && isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            completion?(.failure(.noInternetConnection))
            return
        }

        guard let requestUrl = endpoint.urlString else {
            completion?(.failure(.invalidUrl))
            return
        }

        guard endpoint.allowedMethods.contains(method) else {
            completion?(.failure(.methodNotAllowed))
            return
        }

        let requestHeaders = HTTPHeaders(headers ?? endpoint.headers)

        session.request(requestUrl, method: method, headers: requestHeaders).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
            self?.handleResponse(response, endpoint: endpoint, expecting: responseType, isUserDriven: isUserDriven, completion: completion)
        }
    }

    func performRequestWithParameters<ResponseType: Codable, P: Encodable>(onEndpoint endpoint: APIEndpoint, using method: HTTPMethod, headers: [String: String]? = nil, parameters: P?, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {

        if !networkIsReachable && isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            completion?(.failure(.noInternetConnection))
            return
        }

        guard let requestUrl = endpoint.urlString else {
            completion?(.failure(.invalidUrl))
            return
        }

        guard endpoint.allowedMethods.contains(method) else {
            completion?(.failure(.methodNotAllowed))
            return
        }

        let requestHeaders = HTTPHeaders(headers ?? endpoint.headers)

        session.request(requestUrl, method: method, parameters: parameters, encoder: JSONParameterEncoder.default, headers: requestHeaders).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
            self?.handleResponse(response, endpoint: endpoint, expecting: responseType, isUserDriven: isUserDriven, completion: completion)
        }
    }

    func getImage(fromUrlString urlString: String, completion: APIClientCompletionHandler<UIImage>? = nil) {
        session.request(urlString).responseImage { response in
            if let error = response.error {
                completion?(.failure(.customError(error.localizedDescription)))
                return
            }

            do {
                let image = try response.result.get()
                completion?(.success(image))
            } catch let error {
                completion?(.failure(.customError(error.localizedDescription)))
            }
        }
    }
}

// MARK: - Response handling

struct Nothing: Codable {}

private extension APIClient {
    func handleResponse<ResponseType: Codable>(_ response: AFDataResponse<Any>, endpoint: APIEndpoint, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {

        if case let .failure(error) = response.result, error.isServerTrustEvaluationError, isUserDriven {
            // TODO: Pass error through as object?
            NotificationCenter.default.post(name: .didFailServerTrustEvaluation, object: nil)
            completion?(.failure(.sslPinningFailure))
            return
        }

        if let error = response.error {
            completion?(.failure(.customError(error.localizedDescription)))
            return
        }

        guard let data = response.data else {
            completion?(.failure(.invalidResponse))
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            guard let statusCode = response.response?.statusCode else {
                completion?(.failure(.invalidResponse))
                return
            }

            if statusCode == unauthorizedStatus && endpoint.shouldRespondToUnauthorizedStatus {
                // Unauthorized response
                NotificationCenter.default.post(name: .shouldLogout, object: nil)
                return
            } else if successStatusRange.contains(statusCode) {
                // Successful response
                let decodedResponse = try decoder.decode(responseType, from: data)
                completion?(.success(decodedResponse))
                return
            } else if clientErrorStatusRange.contains(statusCode) {
                // Failed response, client error
                if statusCode == badRequestStatus {
                    let decodedResponseErrors = try decoder.decode(ResponseErrors.self, from: data)
                    let otherErrors = try decoder.decode([String].self, from: data)
                    let errorMessage = decodedResponseErrors.nonFieldErrors?.first ?? otherErrors.first ?? "went_wrong".localized
                    completion?(.failure(.customError(errorMessage)))
                    return
                }
                completion?(.failure(.clientError(statusCode)))
                return
            } else if serverErrorStatusRange.contains(statusCode) {
                // Failed response, server error

                // TODO: Can we remove this and just respond to the error sent back in completion by either showing the error message or not?
                NotificationCenter.default.post(name: isUserDriven ? .outageError : .outageSilentFail, object: nil)
                completion?(.failure(.serverError(statusCode)))
                return
            } else {
                completion?(.failure(.checkStatusCode(statusCode)))
                return
            }
        } catch {
            completion?(.failure(.decodingError))
        }
    }
}
