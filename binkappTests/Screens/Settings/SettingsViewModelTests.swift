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
    var sut = SettingsViewModel(rowsWithActionRequired: [])
    
    func test_sections_returnsANotNilArrayOfSections() {
        XCTAssertNotNil(sut.sections)
    }
    
    func test_title_returnsCorrectTitle() {
        XCTAssertEqual(sut.title, "settings_title".localized)
    }
    
    func test_cellHeight_returnsCorrectHeight() {
        XCTAssertEqual(sut.cellHeight, 60)
    }
    
    func test_rowsCount_returnsCorrectCountForAccountSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 0), 2)
    }
    
    func test_rowsCount_returnsCorrectCountForAppearanceSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 1), 1)
    }

    func test_rowsCount_returnsCorrectCountForSupportSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 2), 3)
    }
    
    func test_rowsCount_returnsCorrectCountForAboutSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 3), 3)
    }
    
    func test_rowsCount_returnsCorrectCountForLegalSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 4), 2)
    }
    
    #if DEBUG
    func test_rowsCount_returnsCorrectCountForDebugSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 5), 1)
    }
    #endif
    
    func test_titleForSection_returnsCorrectTitleForAccountSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 0), "settings_section_account_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForAppearanceSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 1), "settings_section_appearance_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForSupportSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 2), "settings_section_support_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForAboutSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 3), "settings_section_about_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForLegalSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 4), "settings_section_legal_title".localized)
    }
    
    #if DEBUG
    func test_titleForSection_returnsCorrectTitleForDebugSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 5), "settings_section_debug_title".localized)
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
    
    func test_row_returnsCorrectRowForAppearanceRow() {
        let logOut = getSettingsRow(forRow: 0, section: 1)
        XCTAssertEqual(logOut?.title, "Theme")
    }
    
    func test_row_returnsCorrectRowForFAQRow() {
        let faqs = getSettingsRow(forRow: 0, section: 2)
        XCTAssertEqual(faqs?.title, "FAQs")
    }
    
    func test_row_returnsCorrectRowForContactRow() {
        let contact = getSettingsRow(forRow: 1, section: 2)
        XCTAssertEqual(contact?.title, "Contact us")
    }
    
    func test_row_returnsCorrectRowForRateUsRow() {
        let rateApp = getSettingsRow(forRow: 2, section: 2)
        XCTAssertEqual(rateApp?.title, "Rate this app")
    }
    
    func test_row_returnsCorrectRowForSecurityRow() {
        let security = getSettingsRow(forRow: 0, section: 3)
        XCTAssertEqual(security?.title, "Security and privacy")
    }
    
    func test_row_returnsCorrectRowForHowItWorksRow() {
        let howItWorks = getSettingsRow(forRow: 1, section: 3)
        XCTAssertEqual(howItWorks?.title, "How it works")
    }
    
    func test_row_returnsCorrectRowForWhoWeAreRow() {
        let whoWeAre = getSettingsRow(forRow: 2, section: 3)
        XCTAssertEqual(whoWeAre?.title, "Who we are")
    }
    func test_row_returnsCorrectRowForPrivacyRow() {
        let privacy = getSettingsRow(forRow: 0, section: 4)
        XCTAssertEqual(privacy?.title, "Privacy policy")
    }
    
    func test_row_returnsCorrectRowForTAndCRow() {
        let tAndC = getSettingsRow(forRow: 1, section: 4)
        XCTAssertEqual(tAndC?.title, "Terms and conditions")
    }
    
    #if DEBUG
    func test_row_returnsCorrectRowForDebugRow() {
        let debug = getSettingsRow(forRow: 0, section: 5)
        XCTAssertEqual(debug?.title, "Debug")
    }
    #endif
    
    func getSettingsRow(forRow row: Int, section: Int) -> SettingsRow? {
        let indexPath = IndexPath(row: row, section: section)
        return sut.row(atIndexPath: indexPath)
    }
}
