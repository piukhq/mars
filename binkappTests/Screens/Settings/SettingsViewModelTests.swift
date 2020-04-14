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
    var viewModel: SettingsViewModel?
    var settingsFactory: SettingsFactory?

    override func setUp() {
        viewModel = SettingsViewModel(router: MainScreenRouter(delegate: self))
        settingsFactory = SettingsFactory(router: MainScreenRouter(delegate: self))
    }

    override func tearDown() {
        viewModel = nil
    }
    
    func test_sections(){
        XCTAssert(viewModel?.sections != nil)
    }
    
    func test_title() {
        XCTAssertEqual(viewModel?.title, "settings_title".localized)
    }
    
    func test_sections_count() {
        #if DEBUG
        XCTAssertEqual(viewModel?.sectionsCount, 5)
        #else
        XCTAssertEqual(viewModel?.sectionsCount, 4)
        #endif
    }
    
    func cell_height() {
        XCTAssertEqual(viewModel?.cellHeight, 60)
    }
    
    func test_rows_count() {
        let sections = settingsFactory?.sectionData()
        switch sections?.count {
        case 1:
            XCTAssertEqual(viewModel?.rowsCount(forSectionAtIndex: 0), 2)
        case 2:
            XCTAssertEqual(viewModel?.rowsCount(forSectionAtIndex: 1), 3)
        case 3:
            XCTAssertEqual(viewModel?.rowsCount(forSectionAtIndex: 2), 2)
        case 4:
            XCTAssertEqual(viewModel?.rowsCount(forSectionAtIndex: 3), 2)
            #if DEBUG
        case 5:
            XCTAssertEqual(viewModel?.rowsCount(forSectionAtIndex: 4), 1)
            #endif
        default:
            return
        }
    }
    
    func test_section_title() {
        let sections = settingsFactory?.sectionData()
        switch sections?.count {
        case 1:
            XCTAssertEqual(viewModel?.titleForSection(atIndex: 0), "settings_section_account_title".localized)
        case 2:
            XCTAssertEqual(viewModel?.titleForSection(atIndex: 1), "settings_section_support_title".localized)
        case 3:
            XCTAssertEqual(viewModel?.titleForSection(atIndex: 2), "settings_section_about_title".localized)
        case 4:
            XCTAssertEqual(viewModel?.titleForSection(atIndex: 3), "settings_section_legal_title".localized)
            #if DEBUG
        case 5:
            XCTAssertEqual(viewModel?.titleForSection(atIndex: 4), "settings_section_debug_title".localized)
            #endif
        default:
            return
        }
    }
    
    func test_row() {
        let sections = settingsFactory?.sectionData()
        switch sections?.count {
        case 1:
            switch viewModel?.rowsCount(forSectionAtIndex: 1) {
            case 1:
                let preferences = getSettingsRow(forRow: 0, section: 0)
                XCTAssertEqual(preferences?.title, "Preferences")
            case 2:
                let logOut = getSettingsRow(forRow: 1, section: 0)
                XCTAssertEqual(logOut?.title, "Log out")
            default:
                return
            }
        case 2:
            switch viewModel?.rowsCount(forSectionAtIndex: 2) {
            case 1:
                let faqs = getSettingsRow(forRow: 0, section: 1)
                XCTAssertEqual(faqs?.title, "FAQs")
            case 2:
                let contact = getSettingsRow(forRow: 1, section: 1)
                XCTAssertEqual(contact?.title, "Contact us")
            case 3:
                let rateApp = getSettingsRow(forRow: 2, section: 1)
                XCTAssertEqual(rateApp?.title, "Rate this app")
            default:
                return
            }
        case 3:
            switch viewModel?.rowsCount(forSectionAtIndex: 3) {
            case 1:
                let security = getSettingsRow(forRow: 0, section: 2)
                XCTAssertEqual(security?.title, "Security and privacy")
            case 2:
                let howItWorks = getSettingsRow(forRow: 1, section: 2)
                XCTAssertEqual(howItWorks?.title, "How it works")
            default:
                return
            }
        case 4:
            switch viewModel?.rowsCount(forSectionAtIndex: 4) {
            case 1:
                let privacy = getSettingsRow(forRow: 0, section: 3)
                XCTAssertEqual(privacy?.title, "Privacy policy")
            case 2:
                let tAndC = getSettingsRow(forRow: 1, section: 3)
                XCTAssertEqual(tAndC?.title, "Terms and conditions")
            default:
                return
            }
            #if DEBUG
        case 5:
            switch viewModel?.rowsCount(forSectionAtIndex: 5) {
            case 1:
                let debug = getSettingsRow(forRow: 0, section: 4)
                XCTAssertEqual(debug?.title, "Debug")
            default:
                return
            }
            #endif
        default:
            return
        }
    }
    
    func getSettingsRow(forRow row: Int, section: Int) -> SettingsRow? {
        let indexPath = IndexPath(row: 0, section: 0)
        return viewModel?.row(atIndexPath: indexPath)
    }
}

extension SettingsViewModelTests: MainScreenRouterDelegate {
    func router(_ router: MainScreenRouter, didLogin: Bool) {}
}
