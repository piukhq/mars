//
//  NSNumberExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class NSNumberExtensionTests: XCTestCase {
    func test_stringHasTwoDecimals() throws {
        let value: NSNumber = 31.223
        XCTAssertTrue(value.twoDecimalPointString() == "31.22")
    }
    
    func test_stringSelfWithoutDecimals() throws {
        let value: NSNumber = 31
        XCTAssertTrue(value.twoDecimalPointString() == "31")
    }
}
