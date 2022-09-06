//
//  TimeIntervalExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class TimeIntervalExtensionTests: XCTestCase {
    func test_timeIntervalToStringFormat() throws {
        let timeInterval = TimeInterval(11111.22)
        XCTAssertTrue(timeInterval.stringFromTimeInterval() == "03:05:11.219")
    }
}
