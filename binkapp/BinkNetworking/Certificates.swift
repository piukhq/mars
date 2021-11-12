//
//  Certificates.swift
//  binkapp
//
//  Created by Sean Williams on 12/11/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Alamofire
import Foundation

// swiftlint:disable force_try force_unwrapping identifier_name

enum Certificates {
    static let bink = Certificates.certificate(filename: "bink")

    private static func certificate(filename: String) -> SecCertificate {
        let filePath = Bundle.main.path(forResource: filename, ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        let certificate = SecCertificateCreateWithData(nil, data as CFData)!

        return certificate
    }
    
    static func configureSession() -> Session {
        let url = "api.gb.bink.com"
        let evaluators = [
            url:
                PinnedCertificatesTrustEvaluator(certificates: [
                    Certificates.bink
                ])
        ]

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        return Session(configuration: configuration, serverTrustManager: ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: evaluators))
    }
}
