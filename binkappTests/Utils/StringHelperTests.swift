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
}
