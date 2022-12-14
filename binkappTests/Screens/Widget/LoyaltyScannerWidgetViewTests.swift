//
//  LoyaltyScannerWidgetViewTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class LoyaltyScannerWidgetViewTests: XCTestCase {
    
    func test_getStateCorrectStrings() throws {
        var state = LoyaltyScannerWidgetView.WidgetState.enterManually
        XCTAssertTrue(state.title == "Enter manually")
        XCTAssertTrue(state.explainerText == "You can also type in the card details yourself.")
        XCTAssertTrue(state.imageName == "loyalty_scanner_enter_manually")
        
        state = LoyaltyScannerWidgetView.WidgetState.timeout
        XCTAssertTrue(state.title == "Enter manually")
        XCTAssertTrue(state.explainerText == "You can also type in the card details yourself.")
        XCTAssertTrue(state.imageName == "loyalty_scanner_error")
        
        state = LoyaltyScannerWidgetView.WidgetState.unrecognizedBarcode
        XCTAssertTrue(state.title == "Unrecognised barcode")
        XCTAssertTrue(state.explainerText == "Please try adding the card manually.")
        XCTAssertTrue(state.imageName == "loyalty_scanner_error")
    }
    
    func test_propertiesAreCorrect() throws {
        let widget = LoyaltyScannerWidgetView()
        widget.configure()
        
        XCTAssertTrue(widget.getTitleLabel().font == .subtitle)
        XCTAssertTrue(widget.getTitleLabel().text == "Enter manually")
        XCTAssertTrue(widget.getTitleLabel().textColor == Current.themeManager.color(for: .text))
        
        XCTAssertTrue(widget.getExplainerLabel().font == .bodyTextLarge)
        XCTAssertTrue(widget.getExplainerLabel().text == "You can also type in the card details yourself.")
        XCTAssertTrue(widget.getExplainerLabel().numberOfLines == 2)
        XCTAssertTrue(widget.getExplainerLabel().textColor == Current.themeManager.color(for: .text))
    }
    
    func test_timeoutState() throws {
        let widget = LoyaltyScannerWidgetView()
        widget.configure()
        widget.timeout()
        
        XCTAssertTrue(widget.getTitleLabel().text == "Enter manually")
        XCTAssertTrue(widget.getExplainerLabel().text == "You can also type in the card details yourself.")
    }
}
