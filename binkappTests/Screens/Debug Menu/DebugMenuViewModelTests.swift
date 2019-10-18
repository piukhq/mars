//
//  DebugMenuViewModelTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 03/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class DebugMenuViewModelTests: XCTestCase {

    func test_titleText() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)
        XCTAssertEqual(sut.title, "Debug Menu")
    }

    func test_sectionsCount_isCorrect() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)
        XCTAssertEqual(sut.sectionsCount, 1)
    }

    func test_rowCount_isCorrect_forToolsSection() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 0), 3)
    }

    func test_titleText_forToolsSection_isCorrect() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)
        XCTAssertEqual(sut.titleForSection(atIndex: 0), "Tools")
    }

    func test_titleText_forRows_inToolsSection() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)
        
        let versionNumberRow = sut.row(atIndexPath: IndexPath(row: 0, section: 0))
        let endpointRow = sut.row(atIndexPath: IndexPath(row: 1, section: 0))
        let emailAddressRow = sut.row(atIndexPath: IndexPath(row: 2, section: 0))

        XCTAssertEqual(versionNumberRow.title, "Current version")
        XCTAssertEqual(endpointRow.title, "Environment Base URL")
        XCTAssertEqual(emailAddressRow.title, "Current email address")
    }

    func test_subtitleText_forVersionNumberRow_inToolsSection() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)

        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        let versionNumberRow = sut.row(atIndexPath: IndexPath(row: 0, section: 0))
        XCTAssertEqual(versionNumberRow.subtitle, "\(versionNumber ?? "") build \(buildNumber ?? "")")
    }

    func test_subtitleText_forEndpointRow_inToolsSection() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)

        let endpointRow = sut.row(atIndexPath: IndexPath(row: 1, section: 0))
        XCTAssertEqual(endpointRow.subtitle, APIConstants.baseURLString)
    }

    func test_subtitleText_forEmailAddressRow_inToolsSection() {
        let factory = DebugMenuFactory()
        let sut = DebugMenuViewModel(debugMenuFactory: factory)

        let emailAddressRow = sut.row(atIndexPath: IndexPath(row: 2, section: 0))
        XCTAssertEqual(emailAddressRow.subtitle, UserDefaults.standard.string(forKey: .userEmail))
    }

}
