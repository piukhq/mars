//
//  AutomatedTesting_1_LoyaltyCards.swift
//  binkappUITests
//
//  Created by Sean Williams on 07/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_1_LoyaltyCards: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
    func test_0_addIcelandCard_isSuccessful() {
        sleep(10)
        app.buttons["Browse brands"].tap()
        sleep(10)
        app.tables.staticTexts["Iceland"].tap()
        sleep(10)
        app.buttons["Add my card"].tap()
        let cardNumberTextfield = app.textFields["You'll usually find this on the front of your loyalty card."]
        cardNumberTextfield.tap()
        cardNumberTextfield.typeText("6332040000200000002")
        app.buttons["next"].tap()
        app.typeText("one")
        app.buttons["next"].tap()
        app.typeText("rg1 1aa")

        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.buttons["Add card"].tap()
        app.buttons["Done"].tap()

        let backButton = app.navigationBars["binkapp.LoyaltyCardFullDetailsView"].buttons["Back"]
        backButton.tap()
        
        sleep(60)

        // Pull to refresh
        let icelandCell = app.staticTexts["Iceland"]
        let start = icelandCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = icelandCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
        
        sleep(15)
        
        app.staticTexts["Iceland"].tap()
        XCTAssertTrue(app.staticTexts["£1 "].waitForExistence(timeout: 30))
    }
    
    func test_1_addBAndQCard_isSuccessful() {
        sleep(10)
        app.buttons["Browse brands"].tap()
        sleep(10)
        app.tables.staticTexts["B&Q"].tap()
        sleep(10)
        app.buttons["Add my card"].tap()
        let cardNumberTextfield = app.textFields.element
        cardNumberTextfield.tap()
        cardNumberTextfield.typeText("6356661234567891")

        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.buttons["Add card"].tap()

        XCTAssertTrue(app.staticTexts["Tap card to show barcode"].waitForExistence(timeout: 30))
    }
    
    func test_2_viewIcelandBarcode_isSuccessful() {
        app.staticTexts["Iceland"].tap()
        app.staticTexts["Tap card to show barcode"].tap()
        let imageView = app.images["Barcode imageview"]
        XCTAssertTrue(imageView.waitForExistence(timeout: 10))
    }
    
    func test_3_viewBAndQBarcode_isSuccessful() {
        app.staticTexts["B&Q"].tap()
        app.staticTexts["Tap card to show barcode"].tap()
        let imageView = app.images["Barcode imageview"]
        XCTAssertTrue(imageView.waitForExistence(timeout: 10))
    }
    
    func test_4_cardsAreVisibleAfterPullToRefresh_isTrue() {
        let bAndQCell = app.staticTexts["B&Q"]
        let start = bAndQCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = bAndQCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
        
        sleep(10)
        
        XCTAssertTrue(app.staticTexts["B&Q"].exists)
        XCTAssertTrue(app.staticTexts["Iceland"].exists)
    }
    
    func test_5_deleteLoyaltyCards_isSuccessful() {
        app.staticTexts["B&Q"].tap()
        app.staticTexts["Remove this card from Bink"].tap()
        app.buttons["Yes"].tap()
        
        sleep(10)

        app.staticTexts["Iceland"].tap()
        app.staticTexts["Remove this card from Bink"].tap()
        app.buttons["Yes"].tap()
        
        XCTAssertFalse(app.staticTexts["B&Q"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Iceland"].waitForExistence(timeout: 10))
    }
}
