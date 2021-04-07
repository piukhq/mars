//
//  LoyaltyCardsAutomatedTesting.swift
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
        app.buttons["Browse brands"].tap()
        app.tables.staticTexts["Iceland"].tap()
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
        let firstCell = app.staticTexts["Iceland"]
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
        
        sleep(15)
        app.staticTexts["Iceland"].tap()

        XCTAssertTrue(app.staticTexts["£1 "].waitForExistence(timeout: 120))
        
        
//        app.navigationBars["binkapp.TransactionsView"].children(matching: .button).element.tap()
//        scrollViewsQuery.otherElements.containing(.button, identifier:"Tap card to show barcode").children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        elementsQuery.tables/*@START_MENU_TOKEN@*/.staticTexts["Delete Card"]/*[[".cells.staticTexts[\"Delete Card\"]",".staticTexts[\"Delete Card\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.alerts.scrollViews.otherElements.buttons["Yes"].tap()
        
    }
    
    func test_1_addBAndQCard_isSuccessful() {
        app.buttons["Browse brands"].tap()
        app.tables.staticTexts["B&Q"].tap()
        app.buttons["Add my card"].tap()
        let cardNumberTextfield = app.textFields.element
        cardNumberTextfield.tap()
        cardNumberTextfield.typeText("6356661234567891")

        app.toolbars["Toolbar"].buttons["Done"].tap()
        app.buttons["Add card"].tap()

        XCTAssertTrue(app.staticTexts["Tap card to show barcode"].waitForExistence(timeout: 60))
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

}
