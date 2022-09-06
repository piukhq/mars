//
//  LoginResponseTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 19/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class LoginResponseTests: XCTestCase {

    let stubbedValidResponse: [String: String] = [
        "api_key": "aa",
        "email": "1",
        "access_token": "bb",
        "uid": "0"
    ]
    
    let stubbedInvalidResponse: [String: Any?] = [
        "api_key": "aa",
        "email": 1,
        "access_token": "bb",
        "uid": 0
    ]

    func test_ShouldParseCorrectly() throws {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(LoginResponse.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }
    
    func test_jwtIsvalid() throws {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(LoginResponse.self, from: responseData)
        
        XCTAssertNotNil(decodedResponse)
        XCTAssertNotNil(decodedResponse.jwt)
        XCTAssertNotNil(decodedResponse.email)
    }
    
    func test_ShouldParseIncorrectly() throws {
        let responseData = try? JSONSerialization.data(withJSONObject: stubbedInvalidResponse, options: .prettyPrinted)
        let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: responseData!)
        XCTAssertNil(decodedResponse)
    }
}
