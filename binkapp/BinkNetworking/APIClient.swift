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

// swiftlint:disable force_try force_unwrapping identifier_name

// MARK: - Config and init
typealias APIClientCompletionHandler<ResponseType: Any> = (Result<ResponseType, NetworkingError>, HTTPURLResponse?) -> Void

final class APIClient {
    enum Certificates {
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
        case v1_2 = "v=1.2"
        case v1_3 = "v=1.3"
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
        return APIConstants.isProduction
    }
    
    var isPreProduction: Bool {
        return APIConstants.isPreProduction
    }

    var apiVersion: APIVersion = .v1_2

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
    var queryParameters: [String: String]?
    var headers: [BinkHTTPHeader]?
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
                completion?(.failure(error), nil)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest), nil)
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, isUserDriven: request.isUserDriven, completion: completion)
            }
        }
    }

    func performRequestWithBody<ResponseType: Codable, P: Encodable>(_ request: BinkNetworkRequest, body: P?, expecting responseType: ResponseType.Type, completion: APIClientCompletionHandler<ResponseType>?) {
        validateRequest(request) { (validatedRequest, error) in
            if let error = error {
                completion?(.failure(error), nil)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(.failure(.invalidRequest), nil)
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, parameters: body, encoder: JSONParameterEncoder.default, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.handleResponse(response, endpoint: request.endpoint, expecting: responseType, isUserDriven: request.isUserDriven, completion: completion)
            }
        }
    }

    func performRequestWithNoResponse(_ request: BinkNetworkRequest, body: [String: Any]?, completion: ((Bool, NetworkingError?) -> Void)?) {
        validateRequest(request) { [weak self] (validatedRequest, error) in
            if let error = error {
                completion?(false, error)
                return
            }
            guard let validatedRequest = validatedRequest else {
                completion?(false, .invalidRequest)
                return
            }
            session.request(validatedRequest.requestUrl, method: request.method, parameters: body, encoding: JSONEncoding.default, headers: validatedRequest.headers).cacheResponse(using: ResponseCacher.doNotCache).responseJSON { [weak self] response in
                self?.noResponseHandler(response: response, endpoint: request.endpoint, isUserDriven: request.isUserDriven, completion: completion)
            }
        }
    }

    func getImage(fromUrlString urlString: String, completion: APIClientCompletionHandler<UIImage>? = nil) {
        session.request(urlString).responseImage { response in
            if let error = response.error {
                completion?(.failure(.customError(error.localizedDescription)), nil)
                return
            }

            do {
                let image = try response.result.get()
                completion?(.success(image), nil)
            } catch let error {
                completion?(.failure(.customError(error.localizedDescription)), nil)
            }
        }
    }

    private func validateRequest(_ request: BinkNetworkRequest, completion: (ValidatedNetworkRequest?, NetworkingError?) -> Void) {
        if !networkIsReachable && request.isUserDriven {
            NotificationCenter.default.post(name: .noInternetConnection, object: nil)
            completion(nil, .noInternetConnection)
        }
        
        var requestUrl: String?
        if let params = request.queryParameters {
            requestUrl = request.endpoint.urlString(withQueryParameters: params)
        } else {
            requestUrl = request.endpoint.urlString
        }
        guard let url = requestUrl else {
            completion(nil, .invalidUrl)
            return
        }
        
        guard request.endpoint.allowedMethods.contains(request.method) else {
            completion(nil, .methodNotAllowed)
            return
        }

        let requestHeaders = HTTPHeaders(BinkHTTPHeaders.asDictionary(request.headers ?? request.endpoint.headers))
        completion(ValidatedNetworkRequest(requestUrl: url, headers: requestHeaders), nil)
    }
}

// MARK: - Response handling

private extension APIClient {
    func handleResponse<ResponseType: Codable>(_ response: AFDataResponse<Any>, endpoint: APIEndpoint, expecting responseType: ResponseType.Type, isUserDriven: Bool, completion: APIClientCompletionHandler<ResponseType>?) {
        if case let .failure(error) = response.result, error.isServerTrustEvaluationError, isUserDriven {
            NotificationCenter.default.post(name: .didFailServerTrustEvaluation, object: nil)
            completion?(.failure(.sslPinningFailure), response.response)
            return
        }
        
        if let error = response.error {
            completion?(.failure(.customError(error.localizedDescription)), response.response)
            return
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        do {
            guard let statusCode = response.response?.statusCode else {
                completion?(.failure(.invalidResponse), response.response)
                return
            }

            #if DEBUG
            ResponseCodeVisualiser.show(statusCode)
            #endif

            guard let data = response.data else {
                completion?(.failure(.invalidResponse), response.response)
                return
            }
            
            if statusCode == unauthorizedStatus && endpoint.shouldRespondToUnauthorizedStatus {
                // Unauthorized response
                NotificationCenter.default.post(name: .shouldLogout, object: nil)
                return
            } else if successStatusRange.contains(statusCode) {
                // Successful response
                let decodedResponse = try decoder.decode(responseType, from: data)
                completion?(.success(decodedResponse), response.response)
                return
            } else if clientErrorStatusRange.contains(statusCode) {
                // Failed response, client error
                if statusCode == badRequestStatus {
                    let decodedResponseErrors = try? decoder.decode(ResponseErrors.self, from: data)
                    let errorsArray = try? decoder.decode([String].self, from: data)
                    let errorsDictionary = try? decoder.decode([String: String].self, from: data)
                    let errorMessage = decodedResponseErrors?.nonFieldErrors?.first ?? errorsDictionary?.values.first ?? errorsArray?.first
                    if let errorKey = errorsDictionary?.keys.first, let userFacingNetworkingError = UserFacingNetworkingError.errorForKey(errorKey) {
                        completion?(.failure(.userFacingError(userFacingNetworkingError)), response.response)
                        return
                    } else {
                        completion?(.failure(.customError(errorMessage ?? "went_wrong".localized)), response.response)
                        return
                    }
                }
                completion?(.failure(.clientError(statusCode)), response.response)
                return
            } else if serverErrorStatusRange.contains(statusCode) {
                // Failed response, server error
                // TODO: Can we remove this and just respond to the error sent back in completion by either showing the error message or not?
                NotificationCenter.default.post(name: isUserDriven ? .outageError : .outageSilentFail, object: nil)
                completion?(.failure(.serverError(statusCode)), response.response)
                return
            } else {
                completion?(.failure(.checkStatusCode(statusCode)), response.response)
                return
            }
        } catch {
            completion?(.failure(.decodingError), response.response)
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
        
        #if DEBUG
        ResponseCodeVisualiser.show(statusCode)
        #endif

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
