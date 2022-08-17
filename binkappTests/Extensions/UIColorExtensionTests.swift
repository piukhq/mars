//
//  UIColorExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

// swiftlint:disable all

import XCTest
@testable import binkapp

class UIColorExtensionTests: XCTestCase {
    func test_ColoursToHexValue() throws {
        let hexRed = UIColor.red.toHexString()
        let hexBlue = UIColor.blue.toHexString()
        XCTAssertTrue(hexRed == "#ff0000")
        XCTAssertTrue(hexBlue == "#0000ff")
    }
    
    func test_colorShouldBeBinkPurple() throws {
        let color = UIColor.binkPurple
       
        XCTAssertTrue(color.cgColor.components![0] == 180 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 111 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 234 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeGreenOk() throws {
        let color = UIColor.greenOk
       
        XCTAssertTrue(color.cgColor.components![0] == 0 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 193 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 118 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeBlueInactive() throws {
        let color = UIColor.blueInactive
       
        XCTAssertTrue(color.cgColor.components![0] == 177 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 194 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 203 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBeGreyFifty() throws {
        let color = UIColor.greyFifty
       
        XCTAssertTrue(color.cgColor.components![0] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 127 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
    
    func test_colorShouldBesSortBarButton() throws {
        let color = UIColor.sortBarButton
       
        XCTAssertTrue(color.cgColor.components![0] == 177 / 255)
        XCTAssertTrue(color.cgColor.components![1] == 194 / 255)
        XCTAssertTrue(color.cgColor.components![2] == 203 / 255)
        XCTAssertTrue(color.cgColor.components![3] == 1)
    }
}
