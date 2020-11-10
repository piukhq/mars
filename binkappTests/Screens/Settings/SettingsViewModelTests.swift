//
//  SettingsViewModelTests.swift
//  binkappTests
//
//  Created by Pop Dorin on 10/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class SettingsViewModelTests: XCTestCase {
    func test_sections_returnsANotNilArrayOfSections() {
        let sut = SettingsViewModelMock()
        XCTAssertNotNil(sut.sections)
    }
    
    func test_title_returnsCorrectTitle() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.title, "settings_title".localized)
    }
    
    func test_cellHeight_returnsCorrectHeight() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.cellHeight, 60)
    }
    
    func test_rowsCount_returnsCorrectCountForAccountSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 0), 2)
    }
    
    func test_rowsCount_returnsCorrectCountForSupportSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 1), 3)
    }
    
    func test_rowsCount_returnsCorrectCountForAboutSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 2), 2)
    }
    
    func test_rowsCount_returnsCorrectCountForLegalSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 3), 2)
    }
    
    #if DEBUG
    func test_rowsCount_returnsCorrectCountForDebugSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 4), 1)
    }
    #endif
    
    func test_titleForSection_returnsCorrectTitleForAccountSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.titleForSection(atIndex: 0), "settings_section_account_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForSupportSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.titleForSection(atIndex: 1), "settings_section_support_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForAboutSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.titleForSection(atIndex: 2), "settings_section_about_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForLegalSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.titleForSection(atIndex: 3), "settings_section_legal_title".localized)
    }
    
    #if DEBUG
    func test_titleForSection_returnsCorrectTitleForDebugSection() {
        let sut = SettingsViewModelMock()
        XCTAssertEqual(sut.titleForSection(atIndex: 4), "settings_section_debug_title".localized)
    }
    #endif
    
    
    func test_row_returnsCorrectRowForPreferencesRow() {
        let preferences = getSettingsRow(forRow: 0, section: 0)
        XCTAssertEqual(preferences?.title, "Preferences")
    }
    
    func test_row_returnsCorrectRowForLogOutRow() {
        let logOut = getSettingsRow(forRow: 1, section: 0)
        XCTAssertEqual(logOut?.title, "Log out")
    }
    
    func test_row_returnsCorrectRowForFAQRow() {
        let faqs = getSettingsRow(forRow: 0, section: 1)
        XCTAssertEqual(faqs?.title, "FAQs")
    }
    
    func test_row_returnsCorrectRowForContactRow() {
        let contact = getSettingsRow(forRow: 1, section: 1)
        XCTAssertEqual(contact?.title, "Contact us")
    }
    
    func test_row_returnsCorrectRowForRateUsRow() {
        let rateApp = getSettingsRow(forRow: 2, section: 1)
        XCTAssertEqual(rateApp?.title, "Rate this app")
    }
    
    func test_row_returnsCorrectRowForSecurityRow() {
        let security = getSettingsRow(forRow: 0, section: 2)
        XCTAssertEqual(security?.title, "Security and privacy")
    }
    
    func test_row_returnsCorrectRowForHowItWorksRow() {
        let howItWorks = getSettingsRow(forRow: 1, section: 2)
        XCTAssertEqual(howItWorks?.title, "How it works")
    }
    
    func test_row_returnsCorrectRowForPrivacyRow() {
        let privacy = getSettingsRow(forRow: 0, section: 3)
        XCTAssertEqual(privacy?.title, "Privacy policy")
    }
    
    func test_row_returnsCorrectRowForTAndCRow() {
        let tAndC = getSettingsRow(forRow: 1, section: 3)
        XCTAssertEqual(tAndC?.title, "Terms and conditions")
    }
    
    #if DEBUG
    func test_row_returnsCorrectRowForDebugRow() {
        let debug = getSettingsRow(forRow: 0, section: 4)
        XCTAssertEqual(debug?.title, "Debug")
    }
    #endif
    
    func getSettingsRow(forRow row: Int, section: Int) -> SettingsRow? {
        let sut = SettingsViewModelMock()
        let indexPath = IndexPath(row: row, section: section)
        return sut.row(atIndexPath: indexPath)
    }
}
