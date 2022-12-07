//
//  OptionItemListViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 14/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all
class OptionItemListViewControllerTests: XCTestCase {
    static var sut = OptionItemListViewController()
    
    override class func setUp() {
        super.setUp()

        let newestOptionItem = SortOrderOptionItem(isSelected: true, orderType: .newest)
        let customOptionItem = SortOrderOptionItem(isSelected: false, orderType: .custom)
        
        sut.title = "Title"
        sut.items = [newestOptionItem, customOptionItem]
        sut.view
        sut.viewDidLoad()
        sut.loadView()
        
    }

    func test_hasCorrectContentSize() throws {
        XCTAssertEqual(Self.sut.preferredContentSize.width, CGFloat(200))
        XCTAssertEqual(Self.sut.preferredContentSize.height, CGFloat(160))
    }
    
    func test_returnsCorrectNumberOfSections() throws {
        let sections = Self.sut.numberOfSections(in: UITableView())
        XCTAssertTrue(sections == 1)
    }
    
    func test_returnsCorrectNumberOfItems() throws {
        let items = Self.sut.tableView(UITableView(), numberOfRowsInSection: 1)
        XCTAssertTrue(items == 2)
    }
    
    func test_returnsCorrectCellHeight() throws {
        let height = Self.sut.tableView(UITableView(), heightForRowAt: IndexPath(row: 0, section: 1))
        XCTAssertTrue(height == 64)
    }

    func test_returnsValidCell() throws {
        let cell = Self.sut.tableView(Self.sut.getTableView(), cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cell)
    }

}
