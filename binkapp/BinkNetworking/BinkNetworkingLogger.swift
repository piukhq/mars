//
//  BinkNetworkingLogger.swift
//  binkapp
//
//  Created by Sean Williams on 15/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import Alamofire

class BinkNetworkingLogger: EventMonitor {
    private var log: BinkNetworkingLog!
    
    func requestDidResume(_ request: Request) {
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
        ⚡️ Request Started: \(request)
        ⚡️ Body Data: \(body)
        ⚡️ Base URL: \(APIConstants.baseURLString)
        """

        let endpointString = "Request Started: \(request)"
//        debugPrint("SW: \(message)")
        
        log = BinkNetworkingLog(endpoint: endpointString, baseURL: APIConstants.baseURLString, body: body)
        debugPrint("SW: \(log)")
    }
}

extension Request {
    public func debugLog() -> Self {
    #if DEBUG
//       debugPrint("SW: \(self)")
    #endif
    return self
    }
}


struct BinkNetworkingLog {
    let endpoint: String
    let baseURL: String
    let body: String
}
