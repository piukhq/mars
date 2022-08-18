//
//  MagicLinkRequestModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 18/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class MagicLinkRequestModelTests: XCTestCase {
    let stubbedValidResponse: [String: String] = [
        "email": "fff@email.com",
        "slug": "matalan",
        "locale": "GB",
        "bundle_id": "bundle"
    ]
    
    let stubbedInvalidResponse: [String: Any?] = [
        "email": "fff@email.com",
        "slug": 1,
        "locale": "GB",
        "bundle_id": 0
    ]
    
    func test_ShouldParseCorrectly() throws {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MagicLinkRequestModel.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }
    
    func test_ShouldParseIncorrectly() throws {
        let responseData = try? JSONSerialization.data(withJSONObject: stubbedInvalidResponse, options: .prettyPrinted)
        let decodedResponse = try? JSONDecoder().decode(MagicLinkRequestModel.self, from: responseData!)
        XCTAssertNil(decodedResponse)
    }
}
