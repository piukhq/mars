//
//  DebugMenuFactoryTests.swift
//  binkappTests
//
//  Created by Sean Williams on 13/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class DebugMenuFactoryTests: XCTestCase {
    let sut = DebugMenuFactory()
    var sectionOne: DebugMenuSection?
    
    override func setUp() {
        super.setUp()
        sectionOne = sut.makeDebugMenuSections().first
    }

    func test_makeDebugMenuSections_returnsCorrectNumberOfSections() {
        XCTAssertEqual(sut.makeDebugMenuSections().count, 1)
    }

    func test_sectionOne_title_isCorrect() {
        XCTAssertEqual(sectionOne?.title, L10n.debugMenuToolsSectionTitle)
    }
    
    func test_sectionOne_rowCountIsCorrect() {
        XCTAssertEqual(sectionOne?.rows.count, 10)
    }
    
    func test_sectionOne_FirstRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[0].title, "Environment Base URL")
        XCTAssertEqual(sectionOne?.rows[0].subtitle, "api.staging.gb.bink.com")
        XCTAssertEqual(sectionOne?.rows[0].cellType, .titleSubtitle)
    }
    
    func test_sectionOne_SecondRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[1].title, "Allow Custom Bundle and Client on Login")
        XCTAssertEqual(sectionOne?.rows[1].subtitle, "No")
        XCTAssertEqual(sectionOne?.rows[1].cellType, .titleSubtitle)
    }
    
    func test_sectionOne_ThirdRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[2].title, "Loyalty card secondary colour swatches")
        XCTAssertNil(sectionOne?.rows[2].subtitle)
        XCTAssertEqual(sectionOne?.rows[2].cellType, .titleSubtitle)
    }

    func test_sectionOne_FourthRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[3].title, "LPC debug mode")
        XCTAssertEqual(sectionOne?.rows[3].subtitle, "Disabled")
        XCTAssertEqual(sectionOne?.rows[3].cellType, .titleSubtitle)
    }

    func test_sectionOne_FifthRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[4].title, "Force Crash")
        XCTAssertEqual(sectionOne?.rows[4].subtitle, "This will immediately crash the application")
        XCTAssertEqual(sectionOne?.rows[4].cellType, .titleSubtitle)
    }

    func test_sectionOne_SixthRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[5].title, "Response Code Visualiser")
        XCTAssertEqual(sectionOne?.rows[5].subtitle, "Off")
        XCTAssertEqual(sectionOne?.rows[5].cellType, .titleSubtitle)
    }

    func test_sectionOne_SeventhRow_isCorrect() {
        XCTAssertEqual(sectionOne?.rows[6].title, "Apply in-app review rules")
        XCTAssertEqual(sectionOne?.rows[6].subtitle, "No")
        XCTAssertEqual(sectionOne?.rows[6].cellType, .titleSubtitle)
    }
    
    func test_sectionOne_PLLPromptCounterRow_isCorrectType() {
        XCTAssertEqual(sectionOne?.rows[7].title, "")
        XCTAssertNil(sectionOne?.rows[7].subtitle)
        XCTAssertEqual(sectionOne?.rows[7].cellType, .picker(.link))
    }
    
    func test_sectionOne_SeePromptCounterRow_isCorrectType() {
        XCTAssertEqual(sectionOne?.rows[8].title, "")
        XCTAssertNil(sectionOne?.rows[8].subtitle)
        XCTAssertEqual(sectionOne?.rows[8].cellType, .picker(.see))
    }
    
    func test_sectionOne_StorePromptCounterRow_isCorrectType() {
        XCTAssertEqual(sectionOne?.rows[9].title, "")
        XCTAssertNil(sectionOne?.rows[9].subtitle)
        XCTAssertEqual(sectionOne?.rows[9].cellType, .picker(.store))
    }
}
