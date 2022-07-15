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
    
    func test_imageEdgeInsets_returnCorrectValues() {
        XCTAssertEqual(sut.imageEdgeInsets, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        sut.imageView?.image = Asset.iconCheck.image
        XCTAssertEqual(sut.imageEdgeInsets, LayoutHelper.BinkInfoButton.imageEdgeInsets)
    }
    
    func test_titleEdgeInsets_returnCorrectValues() {
        XCTAssertEqual(sut.titleEdgeInsets, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        sut.imageView?.image = Asset.iconCheck.image
        XCTAssertEqual(sut.titleEdgeInsets, LayoutHelper.BinkInfoButton.titleEdgeInsets)
    }
    
    func test_accessibilityIdentifier_returnCorrectValue() {
        sut.imageView?.image = Asset.iconCheck.image
        XCTAssertEqual(sut.accessibilityIdentifier, "Bink info button")
    }
}
