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
        sleep(10)
        AutomatedTesting.loginIntoEnvironment(type: .dev)
        sleep(20)
        
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
        app.buttons["Back"].tap()

        sleep(60)
        
        AutomatedTesting.pullToRefresh(from: .iceland)
        
        // >> Loyalty wallet
        XCTAssertTrue(app.buttons["Browse brands"].exists)
        
        let icelandCell = app.collectionViews.cells["Iceland"]
        icelandCell.tap()
        
        // >> LCD
        XCTAssertTrue(app.navigationBars["binkapp.LoyaltyCardFullDetailsView"].exists)
        XCTAssertTrue(app.buttons["Back"].exists)
        
        app.staticTexts["Link"].tap()
        
        // >> PLL - No payment cards
        XCTAssertTrue(app.navigationBars["binkapp.PLLScreenView"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["close"].waitForExistence(timeout: 10))
        
        app.buttons["Add payment cards"].tap()
        
        // >> Loyalty scanner
        XCTAssertTrue(app.staticTexts["Enter Manually"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["close"].waitForExistence(timeout: 10))

        app.staticTexts["Enter Manually"].tap()
        
        // >> Add payment card
        XCTAssertTrue(app.navigationBars["binkapp.AddPaymentCardView"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["binkapp.AddPaymentCardView"].buttons["close"].exists)


        let cardNumberTextField = app.textFields["Card number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("5555555555554444")

        let expiryTextField = app.textFields["Expiry"]
        expiryTextField.tap()
        app.pickerWheels["01"].swipeUp()
        app.pickerWheels["2021"].swipeUp()
        
        sleep(10)
        
        let nameTextField = app.textFields["Name on card"]
        nameTextField.tap()
        nameTextField.typeText("B Testerson")
        app.buttons["done"].tap()
        app.buttons["Add"].tap()
        
        // >> Terms and conditions
        XCTAssertTrue(app.textViews["Terms and conditions"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["binkapp.ReusableTemplateView"].buttons["close"].waitForExistence(timeout: 10))
        
        app.buttons["I accept"].tap()
        
        sleep(10)
        
        // >> PLL - Payment cards
        if app.staticTexts["Pending title"].exists {
            app.staticTexts["Pending title"].tap()
        } else {
            app.staticTexts["PLL title label"].tap()
        }
        
        app.buttons["close"].tap()
        app.buttons["Back"].tap()
        
        AutomatedTesting.pullToRefresh(from: .iceland)
        
        sleep(10)
        
        icelandCell.tap()
        XCTAssertTrue(app.staticTexts["Linked"].waitForExistence(timeout: 10))
        
        app.tables.cells["Delete Card"].tap()
        app.buttons["Yes"].tap()
        
        sleep(5)
        
        app.buttons["Payment"].tap()
        app.collectionViews.cells["B Testerson"].tap()
        app.tables.cells["Delete this card"].tap()
        app.buttons["Yes"].tap()
    }
}
