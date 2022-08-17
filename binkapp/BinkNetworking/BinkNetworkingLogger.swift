//
//  BinkNetworkingLogger.swift
//  binkapp
//
//  Created by Sean Williams on 15/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation
import Alamofire

//enum QuantumValue: Decodable {
//    case int(Int), string(String)
//
//    init(from decoder: Decoder) throws {
//        if let int = try? decoder.singleValueContainer().decode(Int.self) {
//            self = .int(int)
//            return
//        }
//
//        if let string = try? decoder.singleValueContainer().decode(String.self) {
//            self = .string(string)
//            return
//        }
//
//        throw QuantumError.missingValue
//    }
//
//    enum QuantumError: Error {
//        case missingValue
//    }
//}
//
//struct QuantumResponse: Codable {
//    let response: [String: QuantumValue]
//}

struct AnyCodable: Decodable {
    var value: Any?
    
    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    init(value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else if container.codingPath.isEmpty {
                value = nil
            } else {
                let key = container.codingPath.last?.stringValue

                value = "nil"
//                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

extension AnyCodable: Encodable {
    func encode(to encoder: Encoder) throws {
        if let array = value as? [Any] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = AnyCodable(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = value as? [String: Any] {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = AnyCodable(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(value, EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
            }
        }
    }
}

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
//        print("SW:⚡️ HTTP Status Code: \(response.statusCode)")
//        print("SW:⚡️ Response Time: [\(String(format: "%.04f", elapsedTime)) s]")
        print("SW:⚡️ Response Body: \(responseBody)")
        
//        let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        var anyCodable: AnyCodable?
        do {
            anyCodable = try JSONDecoder().decode(AnyCodable.self, from: data)
//            print("SW: \(anyCodable)")
        } catch {
            print("SW: \(error)")
        }

        let log = BinkNetworkingLog(endpoint: endpoint, baseURL: baseURL, requestBody: requestBody, httpStatusCode: statusCode, responseTime: responseTime, responseBody: anyCodable)
        
        if logs.count == 20 {
            logs.removeFirst()
            logs.append(log)
        } else {
            logs.append(log)
        }
        
        saveLogs()
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
    var responseBody: AnyCodable?
    
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
