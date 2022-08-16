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
    
//    func requestDidResume(_ request: Request) {
//        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
//        let message = """
//        ⚡️ Request Started: \(request)
//        ⚡️ Body Data: \(body)
//        ⚡️ Base URL: \(APIConstants.baseURLString)
//        """
//
//        let endpointString = "Request Started: \(request)"
////        debugPrint("SW: \(message)")
//
//        log = BinkNetworkingLog(endpoint: endpointString, baseURL: APIConstants.baseURLString, body: body)
////        debugPrint("SW: \(log)")
//    }
    
    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        guard
            let task = request.task,
            let urlRequest = task.originalRequest,
            let httpMethod = urlRequest.httpMethod,
            let requestURL = urlRequest.url,
            let metrics = request.metrics
            else {
                return
        }
        
        //: - Request
        let requestBody = urlRequest.urlRequest.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        print("SW:⚡️ \(httpMethod) '\(requestURL.absoluteString)'")
        print("SW:⚡️ Base URL: \(APIConstants.baseURLString)")
        print("SW:⚡️ Request Body: \(requestBody)")
        
        
        //: - Response
        let elapsedTime = metrics.taskInterval.duration
        
        guard let response = response.response else { return }

        if let error = task.error {
            print("SW:⚡️ [Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]:")
            print(error)
        } else {
            print("SW:⚡️ HTTP Status Code: \(response.statusCode)")
            print("SW:⚡️ Response Time: [\(String(format: "%.04f", elapsedTime)) s]")
            
            guard let data = request.data else { return }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                
                if let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("SW:⚡️ Response Body: \(prettyString)")
                }
            } catch {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("SW:⚡️ Response Body: \(errorString)")
                }
            }
        }
        
        logDivider()
    }
    
    private func logDivider() {
        print("SW: --------------------- \n")
    }
}

struct BinkNetworkingLog {
    let endpoint: String
    let baseURL: String
    let body: String
}
