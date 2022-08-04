//
//  BinkInfoButtonTests.swift
//  binkappTests
//
//  Created by Sean Williams on 14/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class BinkInfoButtonTests: XCTestCase, CoreDataTestable {
    var sut: BinkInfoButton!

    override func setUp() {
        super.setUp()
        sut = BinkInfoButton(type: .custom)
    }
    
    func test_accessibilityIdentifier_returnCorrectValue() {
        sut.imageView?.image = Asset.iconCheck.image
        XCTAssertEqual(sut.accessibilityIdentifier, "Bink info button")
    }
}
