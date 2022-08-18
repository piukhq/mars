//
//  StringHelperTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 15/06/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class StringHelperTests: XCTestCase {
    func testString_add_character_every_nth_position() throws {
        let testString = "12345678"
        let modifiedString = testString.insertCharacterInString(step: 2, withCharacter: "-")
        
        XCTAssertEqual(Array(modifiedString)[2], "-")
        XCTAssertEqual(Array(modifiedString)[5], "-")
    }
    
    func testString_textShouldSlice() throws {
        let testString = "12345678"
        let headerString = testString.slice(from: "2", to: "6")
        
        XCTAssertEqual(headerString, "345")
    }
    
    func testString_shouldSplitString() throws {
        let testString = "12345678"
        let headerString = testString.splitStringIntoArray(elementLength: 4)
        
        XCTAssertEqual(headerString[0], "1234")
        XCTAssertEqual(headerString[1], "5678")
    }
    
    func testString_correctTimeFormat() throws {
        let date = 1536080100
        let dateRedeemedString = String.fromTimestamp((date as NSNumber?)?.doubleValue, withFormat: .dayShortMonthYear24HourSecond, prefix: "Date: ")
        
        XCTAssertEqual("Date: 04 Sep 2018 17:55:00", dateRedeemedString)
    }
}
