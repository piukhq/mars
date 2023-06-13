//
//  DebugMenuTableViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 12/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all
class DebugMenuTableViewControllerTests: XCTestCase {

    var sut = DebugMenuTableViewController(viewModel: DebugMenuViewModel(debugMenuFactory: DebugMenuFactory()))

    override func setUp() {
        super.setUp()

        sut.viewDidLoad()
        sut.configureForCurrentTheme()

        resetFlags()
    }

    private func resetFlags() {
        Current.userDefaults.set(false, forDefaultsKey: .lpcDebugMode)
        Current.userDefaults.set(false, forDefaultsKey: .responseCodeVisualiser)
        Current.userDefaults.set(false, forDefaultsKey: .applyInAppReviewRules)
        Current.userDefaults.set(false, forDefaultsKey: .allowCustomBundleClientOnLogin)
    }

    override func tearDown() {
        resetFlags()
    }

    func test_hasCorrectBgForTheme() throws {
        XCTAssertEqual(sut.view.backgroundColor, Current.themeManager.color(for: .viewBackground))
    }

    func test_hasCorrectSections() throws {
        let sections = sut.numberOfSections(in: UITableView())
        XCTAssertEqual(sections, 1)
    }

    func test_sectionHasCorrectTitle() throws {
        let title = sut.tableView(UITableView(), titleForHeaderInSection: 0)
        XCTAssertEqual(title, "Tools")
    }

    func test_sectionHasCorrectRows() throws {
        let rows = sut.tableView(UITableView(), numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 10)
    }

    func test_rowHasValidCell() throws {
        var cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cell)

        cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 7, section: 0))
        XCTAssertNotNil(cell)
    }

    func test_performsCorrectAction() throws {
        sut.debugMenuFactory(DebugMenuFactory(), shouldPerformActionForType: DebugMenuRow.RowType.lpcDebugMode)

        var value = Current.userDefaults.bool(forDefaultsKey: .lpcDebugMode)
        XCTAssertTrue(value)

        sut.debugMenuFactory(DebugMenuFactory(), shouldPerformActionForType: DebugMenuRow.RowType.responseCodeVisualiser)

        value = Current.userDefaults.bool(forDefaultsKey: .responseCodeVisualiser)
        XCTAssertTrue(value)

        sut.debugMenuFactory(DebugMenuFactory(), shouldPerformActionForType: DebugMenuRow.RowType.inAppReviewRules)

        value = Current.userDefaults.bool(forDefaultsKey: .applyInAppReviewRules)
        XCTAssertTrue(value)

        sut.debugMenuFactory(DebugMenuFactory(), shouldPerformActionForType: DebugMenuRow.RowType.customBundleClientLogin)

        value = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
        XCTAssertTrue(value)
    }
}
