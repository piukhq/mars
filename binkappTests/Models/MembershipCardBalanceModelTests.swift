//
//  MembershipCardBalanceModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 17/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

// swiftlint:disable all

import XCTest
@testable import binkapp

class MembershipCardBalanceModelTests: XCTestCase {

    let stubbedValidResponse: [String: Any] = [
        "id": 0,
        "value": 1.0,
        "currency": "GBP",
        "prefix": "£"
    ]

    let stubbedInvalidResponse: [String: Any] = [
        "id": 0,
        "value": 1.0,
        "currency": "GBP",
        "prefix": true
    ]

    func test_membershipCardBalance_validResponse_decodesCorrectly() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MembershipCardBalanceModel.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }

    func test_membershipCardBalance_invalidResponse_failsToDecode() {
        let responseData = try? JSONSerialization.data(withJSONObject: stubbedInvalidResponse, options: .prettyPrinted)
        let decodedResponse = try? JSONDecoder().decode(MembershipCardBalanceModel.self, from: responseData!)
        XCTAssertNil(decodedResponse)
    }

    func test_membershipCardBalance_decodedValues() {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(MembershipCardBalanceModel.self, from: responseData)

        XCTAssertEqual(decodedResponse.apiId, 0)
        XCTAssertEqual(decodedResponse.value, 1.0)
        XCTAssertEqual(decodedResponse.currency, "GBP")
        XCTAssertEqual(decodedResponse.prefix, "£")
    }
}
