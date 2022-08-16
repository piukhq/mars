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
    
    init() {
        readLogsFromDisk()
    }

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
        
        // - Request
        let requestBodyFormatted = urlRequest.urlRequest.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let endpoint = "\(httpMethod) '\(requestURL.absoluteString)'"
        let baseURL = "\(APIConstants.baseURLString)"
        let requestBody = "\(requestBodyFormatted)"
        print("\(httpMethod) '\(requestURL.absoluteString)'")
        print("\(APIConstants.baseURLString)")
        print("\(requestBody)")
        
        // - Response
        guard let response = response.response, let data = request.data else { return }
        let elapsedTime = metrics.taskInterval.duration
        let statusCode = "\(response.statusCode)"
        let responseTime = "[\(String(format: "%.04f", elapsedTime)) s]"
        let responseBody = String(data: data, encoding: .utf8) ?? "Failed to parse data"
        print("SW:⚡️ HTTP Status Code: \(response.statusCode)")
        print("SW:⚡️ Response Time: [\(String(format: "%.04f", elapsedTime)) s]")
        
        let log = BinkNetworkingLog(endpoint: endpoint, baseURL: baseURL, requestBody: requestBody, httpStatusCode: statusCode, responseTime: responseTime, responseBody: "responseBody")
        
        if logs.count == 20 {
            logs.removeFirst()
            logs.append(log)
        } else {
            logs.append(log)
        }
        
        saveLogs()
        print("SW: \(logs.count)")
    }
    
    private func saveLogs() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let encoded = try? encoder.encode(logs), let path = networkLogsFilePath() else { return }

        do {
            try encoded.write(to: path, options: .atomicWrite)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func readLogsFromDisk() {
        guard
            let path = networkLogsFilePath(), let data = try? Data(contentsOf: path),
            let logs = try? JSONDecoder().decode([BinkNetworkingLog].self, from: data)
        else { return }
        self.logs = logs
    }
    
    func networkLogsFilePath() -> URL? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documents?.appendingPathComponent("/networkLogs.txt")
    }
}

struct BinkNetworkingLog: Codable {
    var endpoint: String
    var baseURL: String
    var requestBody: String
    var httpStatusCode: String
    var responseTime: String
    var responseBody: String
    
    enum CodingKeys: String, CodingKey {
        case endpoint = "Endpoint"
        case baseURL = "Base URL"
        case requestBody = "Request Body"
        case httpStatusCode = "HTTP Status Code"
        case responseTime = "Response Time"
        case responseBody = "Response Body"
    }
}

struct BinkLog: Codable {
    let body: String
}
