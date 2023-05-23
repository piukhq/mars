//
//  BinkSwitchTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class BinkSwitchTests: XCTestCase {
    func test_hasCorrectColor() throws {
        let binkSwitch = BinkSwitch()
        binkSwitch.layoutSubviews()
        binkSwitch.isOn = true
        XCTAssertEqual(binkSwitch.onTintColor, .binkBlue)
    }
}
