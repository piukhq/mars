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
    var appearanceSection = 0
    
    override func setUp() {
        super.setUp()
        if sut.sections.contains(where: { $0.title == "Appearance" }) {
            appearanceSection += 2
        }
    }
    
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
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 1), 2)
    }
    
    func test_rowsCount_returnsCorrectCountForAppearanceSection() {
        guard appearanceSection == 1 else { return }
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: appearanceSection), 1)
    }

    func test_rowsCount_returnsCorrectCountForSupportSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 2 + appearanceSection), 3)
    }
    
    func test_rowsCount_returnsCorrectCountForAboutSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 3 + appearanceSection), 3)
    }
    
    func test_rowsCount_returnsCorrectCountForLegalSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 4 + appearanceSection), 2)
    }
    
    #if DEBUG
    func test_rowsCount_returnsCorrectCountForDebugSection() {
        XCTAssertEqual(sut.rowsCount(forSectionAtIndex: 5 + appearanceSection), 1)
    }
    #endif
    
    func test_titleForSection_returnsCorrectTitleForAccountSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 1), "settings_section_account_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForAppearanceSection() {
        guard appearanceSection == 1 else { return }
        XCTAssertEqual(sut.titleForSection(atIndex: 1), "settings_section_appearance_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForSupportSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 2 + appearanceSection), "settings_section_support_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForAboutSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 3 + appearanceSection), "settings_section_about_title".localized)
    }
    
    func test_titleForSection_returnsCorrectTitleForLegalSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 4 + appearanceSection), "settings_section_legal_title".localized)
    }
    
    #if DEBUG
    func test_titleForSection_returnsCorrectTitleForDebugSection() {
        XCTAssertEqual(sut.titleForSection(atIndex: 0), "settings_section_debug_title".localized)
    }
    #endif
    
    
    func test_row_returnsCorrectRowForPreferencesRow() {
        let preferences = getSettingsRow(forRow: 0, section: 1)
        XCTAssertEqual(preferences?.title, "Preferences")
    }
    
    func test_row_returnsCorrectRowForLogOutRow() {
        let logOut = getSettingsRow(forRow: 1, section: 1)
        XCTAssertEqual(logOut?.title, "Log out")
    }
    
    func test_row_returnsCorrectRowForAppearanceRow() {
        guard appearanceSection == 1 else { return }
        let logOut = getSettingsRow(forRow: 0, section: 2)
        XCTAssertEqual(logOut?.title, "Theme")
    }
    
    func test_row_returnsCorrectRowForFAQRow() {
        let faqs = getSettingsRow(forRow: 0, section: 2 + appearanceSection)
        XCTAssertEqual(faqs?.title, "FAQs")
    }
    
    func test_row_returnsCorrectRowForContactRow() {
        let contact = getSettingsRow(forRow: 1, section: 2 + appearanceSection)
        XCTAssertEqual(contact?.title, "Contact us")
    }
    
    func test_row_returnsCorrectRowForRateUsRow() {
        let rateApp = getSettingsRow(forRow: 2, section: 2 + appearanceSection)
        XCTAssertEqual(rateApp?.title, "Rate this app")
    }
    
    func test_row_returnsCorrectRowForSecurityRow() {
        let security = getSettingsRow(forRow: 0, section: 3 + appearanceSection)
        XCTAssertEqual(security?.title, "Security and privacy")
    }
    
    func test_row_returnsCorrectRowForHowItWorksRow() {
        let howItWorks = getSettingsRow(forRow: 1, section: 3 + appearanceSection)
        XCTAssertEqual(howItWorks?.title, "How it works")
    }
    
    func test_row_returnsCorrectRowForWhoWeAreRow() {
        let whoWeAre = getSettingsRow(forRow: 2, section: 3 + appearanceSection)
        XCTAssertEqual(whoWeAre?.title, "Who we are")
    }
    func test_row_returnsCorrectRowForPrivacyRow() {
        let privacy = getSettingsRow(forRow: 0, section: 4 + appearanceSection)
        XCTAssertEqual(privacy?.title, "Privacy policy")
    }
    
    func test_row_returnsCorrectRowForTAndCRow() {
        let tAndC = getSettingsRow(forRow: 1, section: 4 + appearanceSection)
        XCTAssertEqual(tAndC?.title, "Terms and conditions")
    }
    
    #if DEBUG
    func test_row_returnsCorrectRowForDebugRow() {
        let debug = getSettingsRow(forRow: 0, section: 0)
        XCTAssertEqual(debug?.title, "Debug")
    }
    #endif
    
    func getSettingsRow(forRow row: Int, section: Int) -> SettingsRow? {
        let indexPath = IndexPath(row: row, section: section)
        return sut.row(atIndexPath: indexPath)
    }
}
