//
//  AutomatedTesting_5_WireframesNavigation.swift
//  binkappUITests
//
//  Created by Sean Williams on 09/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_5_WireframesNavigation: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
    }
    
    func test_0_lcdModule_noPaymentCards_navigationIsCorrect() {
        AutomatedTesting().loginIntoEnvironment(type: .dev)
        sleep(10)
        
        app.buttons["Browse brands"].tap()
        app.tables.cells["Iceland"].tap()
        sleep(10)
        app.buttons["Add my card"].tap()
        let cardNumberTextfield = app.textFields["Bonus card number"]
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
        let icelandCell = app.collectionViews.cells["Iceland"]
        let start = icelandCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = icelandCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
        
        // >> Loyalty wallet
        XCTAssertTrue(app.buttons["Browse brands"].exists)
        
        icelandCell.tap()
        
        // >> LCD
        XCTAssertTrue(app.navigationBars["binkapp.LoyaltyCardFullDetailsView"].exists)
        XCTAssertTrue(app.buttons["Back"].exists)

        app.staticTexts["Link"].tap()
        
        // >> PLL - No payment cards
        XCTAssertTrue(app.navigationBars["binkapp.PLLScreenView"].exists)
        XCTAssertTrue(app.buttons["close"].exists)

        app.buttons["Add payment cards"].tap()
        
        // >> Loyalty scanner
        XCTAssertTrue(app.staticTexts["Enter Manually"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["close"].exists)

        app.staticTexts["Enter Manually"].tap()
        
        // >> Add payment card
        XCTAssertTrue(app.navigationBars["binkapp.AddPaymentCardView"].exists)
        XCTAssertTrue(app.navigationBars["binkapp.AddPaymentCardView"].buttons["close"].exists)

        let cardNumberTextField = app.textFields["Card number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("5555555555554444")

        let expiryTextField = app.textFields["Expiry"]
        expiryTextField.tap()
        app.pickerWheels["01"].swipeUp()
        app.pickerWheels["2021"].swipeUp()
        
        sleep(5)
        
        let nameTextField = app.textFields["Name on card"]
        nameTextField.tap()
        nameTextField.typeText("B Testerson")
        app.buttons["done"].tap()
        app.buttons["Add"].tap()
        
        // >> Terms and conditions
        XCTAssertTrue(app.textViews["Terms and conditions"].exists)
        XCTAssertTrue(app.navigationBars["binkapp.ReusableTemplateView"].buttons["close"].exists)
        
        app.buttons["I accept"].tap()
        
        sleep(5)
        
        // >> PLL - Payment cards
        if app.staticTexts["Pending title"].exists {
            app.staticTexts["Pending title"].tap()
        } else {
            app.staticTexts["PLL title label"].tap()
        }
        
        app.buttons["close"].tap()
        app.buttons["Back"].tap()
        
        start.press(forDuration: 0, thenDragTo: finish)
        
        sleep(10)
        
        icelandCell.tap()
        XCTAssertTrue(app.staticTexts["Linked"].waitForExistence(timeout: 10))
    }
}
