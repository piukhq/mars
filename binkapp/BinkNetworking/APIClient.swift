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
    private let noResponseStatus = 204
    private let clientErrorStatusRange = 400...499
    private let badRequestStatus = 400
    private let unauthorizedStatus = 401
    private let serverErrorStatusRange = 500...599

    private let reachabilityManager = NetworkReachabilityManager()
    private let session: Session

    init() {
        let url = EnvironmentType.production.rawValue
        let evaluators = [
            url:
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

struct BinkNetworkRequest {
    var endpoint: APIEndpoint
    var method: HTTPMethod
    var headers: [String: String]?
    var isUserDriven: Bool
}
struct ValidatedNetworkRequest {
    var requestUrl: String
    var headers: HTTPHeaders
}

extension APIClient {
    func performRequest<ResponseType: Codable>(_ request: BinkNetworkRequest, expecting responseType: ResponseType.Type, completion: APIClientCompletionHandler<ResponseType>?) {
        validateRequest(request) { [weak self] (validatedRequest, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest))
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, isUserDriven: request.isUserDriven, completion: completion)
            }
        }
    }

    func performRequestWithParameters<ResponseType: Codable, P: Encodable>(onEndpoint endpoint: APIEndpoint, using method: HTTPMethod, headers: [String: String]? = nil, parameters: P?, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {
        let request = BinkNetworkRequest(endpoint: endpoint, method: method, headers: headers, isUserDriven: isUserDriven)
        validateRequest(request) { (validatedRequest, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest))
                return
            }
            session.request(validatedRequest.requestUrl, method: method, parameters: parameters, encoder: JSONParameterEncoder.default, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.handleResponse(response, endpoint: endpoint, expecting: responseType, isUserDriven: isUserDriven, completion: completion)
            }
        }
    }

    func performRequestWithNoResponse(onEndpoint endpoint: APIEndpoint, using method: HTTPMethod, headers: [String: String]? = nil, parameters: [String: Any]?, isUserDriven: Bool, completion: ((Bool, NetworkingError?) -> Void)?) {
        let request = BinkNetworkRequest(endpoint: endpoint, method: method, headers: headers, isUserDriven: isUserDriven)
        validateRequest(request) { [weak self] (validatedRequest, error) in
            if let error = error {
                completion?(false, error)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(false, .invalidRequest)
                return
            }
            session.request(validatedRequest.requestUrl, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.noResponseHandler(response: response, endpoint: endpoint, isUserDriven: isUserDriven, completion: completion)
            }
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

private extension APIClient {
    func validateRequest(_ request: BinkNetworkRequest, completion: (ValidatedNetworkRequest?, NetworkingError?) -> Void) {
        if !networkIsReachable && request.isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            completion(nil, .noInternetConnection)
        }
        guard let requestUrl = request.endpoint.urlString else {
            completion(nil, .invalidUrl)
            return
        }
        guard request.endpoint.allowedMethods.contains(request.method) else {
            completion(nil, .methodNotAllowed)
            return
        }

        let requestHeaders = HTTPHeaders(request.headers ?? request.endpoint.headers)
        completion(ValidatedNetworkRequest(requestUrl: requestUrl, headers: requestHeaders), nil)
    }

    func handleResponse<ResponseType: Codable>(_ response: AFDataResponse<Any>, endpoint: APIEndpoint, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {
        if case let .failure(error) = response.result, error.isServerTrustEvaluationError, isUserDriven {
            NotificationCenter.default.post(name: .didFailServerTrustEvaluation, object: nil)
            completion?(.failure(.sslPinningFailure))
            return
        }

        if let error = response.error {
            completion?(.failure(.customError(error.localizedDescription)))
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            guard let statusCode = response.response?.statusCode else {
                completion?(.failure(.invalidResponse))
                return
            }

            guard let data = response.data else {
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
                    let decodedResponseErrors = try? decoder.decode(ResponseErrors.self, from: data)
                    let errorsArray = try? decoder.decode([String].self, from: data)
                    let errorsDictionary = try? decoder.decode([String: String].self, from: data)
                    let errorMessage = decodedResponseErrors?.nonFieldErrors?.first ?? errorsDictionary?.values.first ?? errorsArray?.first
                    completion?(.failure(.customError(errorMessage ?? "went_wrong".localized)))
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

    func noResponseHandler(response: AFDataResponse<Any>, endpoint: APIEndpoint, isUserDriven: Bool, completion: ((Bool, NetworkingError?) -> Void)?) {
        if case let .failure(error) = response.result, error.isServerTrustEvaluationError, isUserDriven {
            NotificationCenter.default.post(name: .didFailServerTrustEvaluation, object: nil)
            completion?(false, .sslPinningFailure)
            return
        }

        if let error = response.error {
            completion?(false, .customError(error.localizedDescription))
            return
        }

        guard let statusCode = response.response?.statusCode else {
            completion?(false, .invalidResponse)
            return
        }

        if statusCode == unauthorizedStatus && endpoint.shouldRespondToUnauthorizedStatus {
            // Unauthorized response
            NotificationCenter.default.post(name: .shouldLogout, object: nil)
            return
        } else if successStatusRange.contains(statusCode) {
            // Successful response
            completion?(true, nil)
            return
        } else if serverErrorStatusRange.contains(statusCode) {
            // Failed response, server error
            // TODO: Can we remove this and just respond to the error sent back in completion by either showing the error message or not?
            NotificationCenter.default.post(name: isUserDriven ? .outageError : .outageSilentFail, object: nil)
            completion?(false, .serverError(statusCode))
            return
        } else {
            completion?(false, .checkStatusCode(statusCode))
            return
        }
    }
}
