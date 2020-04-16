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
    private let reachabilityManager = NetworkReachabilityManager()
    private let session: Session

    enum NetworkStrength: String {
        case wifi
        case cellular
        case unknown
    }

    enum ApiVersion: String {
        case v1_1 = "v=1.1"
        case v1_2 = "v=1.2"
    }

    struct Certificates {
        static let bink = Certificates.certificate(filename: "bink")

        private static func certificate(filename: String) -> SecCertificate {
            let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            let certificate = SecCertificateCreateWithData(nil, data as CFData)!

            return certificate
        }
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
        return APIConstants.baseURLString == APIConstants.productionBaseURL
    }

    var apiVersion: ApiVersion = .v1_1

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
    func performRequest<ResponseType, Parameters: Codable>(onEndpoint endpoint: APIEndpoint, using method: HTTPMethod, parameters: Parameters? = nil, isUserDriven: Bool, completion: (Result<ResponseType, Error>) -> Void) {
        
    }
}

// MARK: - Response handling

private extension APIClient {
    func handleResponse<ResponseType: Codable>(_ response: AFDataResponse<Any>, endpoint: APIEndpoint, isUserDriven: Bool, completion: (Result<ResponseType, Error>) -> Void) {

    }
}
