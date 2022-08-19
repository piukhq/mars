//
//  PaymentCardCreateModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 19/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class PaymentCardCreateModelTests: XCTestCase {

    static var model = PaymentCardCreateModel(fullPan: "1234 1234", nameOnCard: "Rick Morty", month: 4, year: 2020)
        
    let stubbedValidResponse: [String: Any?] = [
        "fullPan": "5454 5454 5454 5454",
        "nameOnCard": "1",
        "month": 2,
        "year": 2020,
        "cardType": nil,
        "uuid": "aa"
    ]
    
    override class func setUp() {
        super.setUp()
        model.cardType = .visa
        model.uuid = "aa"
    }

    func test_ShouldParseCorrectly() throws {
        let responseData = try! JSONSerialization.data(withJSONObject: stubbedValidResponse, options: .prettyPrinted)
        let decodedResponse = try! JSONDecoder().decode(PaymentCardCreateModel.self, from: responseData)
        XCTAssertNotNil(decodedResponse)
    }
    
    func test_preficIsCorrect() throws {
        XCTAssertTrue(Self.model.cardType!.redactedPrefix == "••••   ••••   ••••   ")
    }
    
    func test_LogosWhenVisa() throws {
        Self.model.cardType = .visa
        XCTAssertTrue(Self.model.cardType!.logoName == "cardPaymentLogoVisa")
        
        XCTAssertTrue(Self.model.cardType!.sublogoName == "cardPaymentSublogoVisa")
    }
    
    func test_LogosWhenAmex() throws {
        Self.model.cardType = .amex
        XCTAssertTrue(Self.model.cardType!.logoName == "cardPaymentLogoAmEx")
        
        XCTAssertTrue(Self.model.cardType!.sublogoName == "cardPaymentSublogoAmEx")
    }
    
    func test_LogosWhenMastercard() throws {
        Self.model.cardType = .mastercard
        XCTAssertTrue(Self.model.cardType!.logoName == "cardPaymentLogoMastercard")
        
        XCTAssertTrue(Self.model.cardType!.sublogoName == "cardPaymentSublogoMasterCard")
    }
    
    func test_SchemeVisa() throws {
        Self.model.cardType = .visa
        XCTAssertEqual(Self.model.cardType!.paymentSchemeIdentifier, 0)
    }
    
    func test_SchemeAmex() throws {
        Self.model.cardType = .amex
        XCTAssertEqual(Self.model.cardType!.paymentSchemeIdentifier, 2)
    }
    
    func test_SchemeMastercard() throws {
        Self.model.cardType = .mastercard
        XCTAssertEqual(Self.model.cardType!.paymentSchemeIdentifier, 1)
    }
    
    func test_isValid() throws {
        Self.model.cardType = .mastercard
        XCTAssertEqual(Self.model.cardType!.fullyValidate("5454545454545454"), true)
    }
    
    func test_isLengthCorrect() throws {
        Self.model.fullPan = "5454 5454 5454 5454"
        let values = Self.model.cardType!.lengthRange()
        XCTAssertEqual(values.length, 16)
        XCTAssertEqual(values.whitespaceIndexes.count, 3)
    }
}
