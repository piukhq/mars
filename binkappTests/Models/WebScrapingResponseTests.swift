//
//  WebScrapingResponseTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 25/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

// swiftlint:disable all

import XCTest
@testable import binkapp

final class WebScrapingResponseTests: XCTestCase {
    let stubbedValidResponse: [String: Any] = [
        "points": "100",
        "did_attempt_login": false,
        "error_message": "",
        "user_action_required": false,
        "user_action_complete": false
    ]

    let stubbedInvalidResponse: [String: Any] = [
        "points": 100,
        "did_attempt_login": "",
        "error_message": true,
        "user_action_required": false,
        "user_action_complete": ""
    ]

    func test_validResponse_decodesCorrectly() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(WebScrapingResponse.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }

    func test_invalidResponse_failsToDecode() {
        let responseData = try? JSONSerialization.data(withJSONObject: stubbedInvalidResponse, options: .prettyPrinted)
        let decodedResponse = try? JSONDecoder().decode(WebScrapingResponse.self, from: responseData!)
        XCTAssertNil(decodedResponse)
    }
    
    func test_pointsValue() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(WebScrapingResponse.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
        
        XCTAssertTrue(decodedResponse.pointsValue == 100)
    }
}
