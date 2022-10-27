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
    
    static var textField = BinkTextField()
    
    func test_propertiesHaveCorrectValues() throws {
        Current.themeManager.setTheme(Theme(type: .light))
        Self.textField.layoutSubviews()
        
        XCTAssertTrue(Self.textField.borderStyle == .none)
        
        XCTAssertTrue(Self.textField.layer.backgroundColor == Current.themeManager.color(for: .walletCardBackground).cgColor)
        
        XCTAssertTrue(Self.textField.textColor == Current.themeManager.color(for: .text))
        
        XCTAssertTrue(Self.textField.tintColor == Current.themeManager.color(for: .text))
    }
    
    func test_colourCorrectForTheme() throws {
        Current.themeManager.setTheme(Theme(type: .light))
        Self.textField.layoutSubviews()
        
        XCTAssertTrue(Self.textField.overrideUserInterfaceStyle == .light)
        
        Current.themeManager.setTheme(Theme(type: .dark))
        Self.textField.layoutSubviews()
        
        XCTAssertTrue(Self.textField.overrideUserInterfaceStyle == .dark)
        
        Current.themeManager.setTheme(Theme(type: .system))
        Self.textField.layoutSubviews()
        
        XCTAssertTrue(Self.textField.overrideUserInterfaceStyle == .unspecified)
    }
}
