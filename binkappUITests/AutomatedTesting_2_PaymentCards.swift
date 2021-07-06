//
//  AutomatedTesting_2_PaymentCards.swift
//  binkappUITests
//
//  Created by Sean Williams on 06/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_2_PaymentCards: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
    }

    func test_0_addMastercard_isSuccessful() {
        app.buttons["Payment"].tap()
        app.collectionViews.cells["Wallet prompt"].tap()
        
        // Camera access alert
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let okButton = springboard.buttons["OK"]
        if okButton.waitForExistence(timeout: 1) { // <<<<<<<<<<<<<<<<<< change to 10
            okButton.tap()
        }
        
        app.staticTexts["Enter Manually"].tap()

        let cardNumberTextField = app.textFields["Card number"]
        cardNumberTextField.tap()
        cardNumberTextField.typeText("5555555555554444")

        let expiryTextField = app.textFields["Expiry"]
        expiryTextField.tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["01"]/*[[".pickers.pickerWheels[\"01\"]",".pickerWheels[\"01\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        app/*@START_MENU_TOKEN@*/.pickerWheels["2021"]/*[[".pickers.pickerWheels[\"2021\"]",".pickerWheels[\"2021\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        
        sleep(5)
        
        let nameTextField = app.textFields["Name on card"]
        nameTextField.tap()
        nameTextField.typeText("B Testerson")
        app/*@START_MENU_TOKEN@*/.buttons["done"]/*[[".keyboards",".buttons[\"done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Add"].tap()
        app.buttons["I accept"].tap()
        
        XCTAssertTrue(app.staticTexts["B Testerson"].waitForExistence(timeout: 10))
    }
    
    func test_1_PLL_link_isSuccessful() {
        sleep(1) // <<<<<<<<<<<<<<<<<< change to 10
        app.buttons["Browse brands"].tap()
        sleep(1)
        app.tables.cells["Iceland"].tap()
        sleep(1)
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
        
        sleep(1)
        
        app.buttons["Payment"].tap()
        app.collectionViews.cells["B Testerson"].tap()
        
        XCTAssertTrue(app.staticTexts["Linked to 1 loyalty card"].waitForExistence(timeout: 10))
    }
    
    func test_2_cardIsVisibleAfterPullToRefresh_isTrue() {
        app.buttons["Payment"].tap()

        let paymentCardCell = app.collectionViews.cells["B Testerson"]
        let start = paymentCardCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = paymentCardCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
        
        XCTAssertTrue(paymentCardCell.waitForExistence(timeout: 10))
    }
    
    func test_3_deleteIcelandAndPaymentCards_isSuccessful() {
        app.collectionViews.cells["Iceland"].tap()
        app.tables.cells["Delete Card"].tap()
        app.buttons["Yes"].tap()
        
        XCTAssertFalse(app.collectionViews.cells["Iceland"].waitForExistence(timeout: 10))

        app.buttons["Payment"].tap()
        app.collectionViews.cells["B Testerson"].tap()
        app.tables.cells["Delete this card"].tap()
        app.buttons["Yes"].tap()

        XCTAssertFalse(app.collectionViews.cells["B Testerson"].waitForExistence(timeout: 10))
    }
}
