//
//  binkappUITests.swift
//  binkappUITests
//
//  Created by Karl Sigiscar on 04/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import XCTest
//@testable import binkapp

class binkappUITests: XCTestCase {
    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        print("TESTING")
    }
}
