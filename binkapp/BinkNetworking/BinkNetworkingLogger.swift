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
    private var logs: [BinkNetworkingLog] = []
    private var binkLog: BinkLog!

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
        let requestBodyFormatted = urlRequest.urlRequest.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let endpoint = "\(httpMethod) '\(requestURL.absoluteString)'"
        let baseURL = "\(APIConstants.baseURLString)"
        let requestBody = "\(requestBodyFormatted)"
        print("\(httpMethod) '\(requestURL.absoluteString)'")
        print("\(APIConstants.baseURLString)")
        print("\(requestBody)")
        
        //: - Response
        let elapsedTime = metrics.taskInterval.duration
        
        guard let response = response.response else { return }

        let statusCode = "\(response.statusCode)"
        let responseTime = "[\(String(format: "%.04f", elapsedTime)) s]"
        print("SW:⚡️ HTTP Status Code: \(response.statusCode)")
        print("SW:⚡️ Response Time: [\(String(format: "%.04f", elapsedTime)) s]")
        
        guard let data = request.data else { return }
        var responseBody = ""

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .withoutEscapingSlashes)

            if let prettyString = String(data: prettyData, encoding: .utf8) {
                responseBody = prettyString
                print("SW:⚡️ Response Body: \(prettyString)")
            }
        } catch {
            if let errorString = String(data: data, encoding: .utf8) {
                responseBody = errorString
                print("SW:⚡️ Response Body: \(errorString)")
            }
        }

        logDivider()
        
        let log = BinkNetworkingLog(endpoint: endpoint, baseURL: baseURL, requestBody: requestBody, httpStatusCode: statusCode, responseTime: responseTime, responseBody: responseBody)
        logs.append(log)
        saveLogs()
    }
    
    private func saveLogs() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let encoded = try? encoder.encode(logs) else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let path = documents?.appendingPathComponent("/networkLogs.nal") else { return }
        
        do {
            try encoded.write(to: path, options: .atomicWrite)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func logDivider() {
        print("SW: --------------------- \n")
    }
}

struct BinkNetworkingLog: Codable {
    let endpoint: String
    let baseURL: String
    let requestBody: String
    let httpStatusCode: String
    let responseTime: String
    let responseBody: String
}

struct BinkLog: Codable {
    let body: String
}
