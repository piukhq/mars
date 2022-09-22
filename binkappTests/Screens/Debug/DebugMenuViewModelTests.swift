//
//  DebugMenuViewModelTests.swift
//  binkappTests
//
//  Created by Sean Williams on 13/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class DebugMenuViewModelTests: XCTestCase {
    private let sut = DebugMenuViewModel(debugMenuFactory: DebugMenuFactory())

    func test_sectionsArray_returnsCorrectSectionCount() {
        XCTAssertEqual(sut.sections.count, 1)
    }
    
    func test_title_isCorrect() {
        XCTAssertEqual(sut.title, "Debug Menu")
    }
    
    func test_sectionsCount_returnsCorrectSectionCount() {
        XCTAssertEqual(sut.sectionsCount, 1)
    }
    
    func test_cellHeight_returnsCorrectSize() {
        XCTAssertEqual(sut.cellHeight(atIndex: 0), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 1), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 2), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 3), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 4), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 5), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 6), 60.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 7), 80.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 8), 80.0)
        XCTAssertEqual(sut.cellHeight(atIndex: 9), 80.0)
    }
    
    func test_rowsCount_returnsCorrect_rowCountForSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 0), 10)
    }
    
    func test_correctTitle_isReturnedForSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 0), "Tools")
    }
    
    func test_correctRowReturned_forIndexPath() {
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 0, section: 0)).title, "Environment Base URL")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 1, section: 0)).title, "Allow Custom Bundle and Client on Login")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 2, section: 0)).title, "Loyalty card secondary colour swatches")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 3, section: 0)).title, "LPC debug mode")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 4, section: 0)).title, "Force Crash")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 5, section: 0)).title, "Response Code Visualiser")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 6, section: 0)).title, "Apply in-app review rules")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 7, section: 0)).title, "")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 8, section: 0)).title, "")
        XCTAssertEqual(sut.row(atIndexPath: IndexPath(row: 9, section: 0)).title, "")
    }
}
