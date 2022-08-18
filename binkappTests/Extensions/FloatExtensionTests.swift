//
//  FloatExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 18/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class FloatExtensionTests: XCTestCase {
    func test_hasDecimals() throws {
        let f: Float = 1.1
        XCTAssertTrue(f.hasDecimals)
    }
}
