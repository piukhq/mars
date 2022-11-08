//
//  BinkTextFieldTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 26/10/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class BinkTextFieldTests: XCTestCase {
    
    var textField = BinkTextField()
    
    func test_propertiesHaveCorrectValues() throws {
        Current.themeManager.setTheme(Theme(type: .light))
        textField.layoutSubviews()
        
        XCTAssertTrue(textField.borderStyle == .none)
        
        XCTAssertTrue(textField.layer.backgroundColor == Current.themeManager.color(for: .walletCardBackground).cgColor)
        
        XCTAssertTrue(textField.textColor == Current.themeManager.color(for: .text))
        
        XCTAssertTrue(textField.tintColor == Current.themeManager.color(for: .text))
    }
    
    func test_colourCorrectForTheme() throws {
        Current.themeManager.setTheme(Theme(type: .light))
        textField.layoutSubviews()
        
        XCTAssertTrue(textField.overrideUserInterfaceStyle == .light)
        
        Current.themeManager.setTheme(Theme(type: .dark))
        textField.layoutSubviews()
        
        XCTAssertTrue(textField.overrideUserInterfaceStyle == .dark)
        
        Current.themeManager.setTheme(Theme(type: .system))
        textField.layoutSubviews()
        
        XCTAssertTrue(textField.overrideUserInterfaceStyle == .unspecified)
    }
}
