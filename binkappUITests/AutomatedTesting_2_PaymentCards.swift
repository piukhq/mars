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
        app.tabBars["Tab Bar"].buttons["Payment"].tap()
        
//        app.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["Collect rewards automatically for select loyalty cards by linking them to your payment cards."]/*[[".cells.staticTexts[\"Collect rewards automatically for select loyalty cards by linking them to your payment cards.\"]",".staticTexts[\"Collect rewards automatically for select loyalty cards by linking them to your payment cards.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.cells["Wallet prompt"].tap()
        
        // OK access to camera?
        

        app.collectionViews.cells["Wallet prompt"].children(matching: .other).element.children(matching: .other).element.tap()
        app.alerts["“Bink β” Would Like to Access the Camera"].scrollViews.otherElements.buttons["OK"].tap()
                
        
//        app.staticTexts["Enter Manually"].tap()
        app.images["Widget imageView"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let collectionViewsQuery = elementsQuery.collectionViews
        let cardNumberTextField = collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Card number"]/*[[".cells",".textFields[\"xxxx xxxx xxxx xxxx\"]",".textFields[\"Card number\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        cardNumberTextField.tap()
//        cardNumberTextField.tap()
        
        let doneButton = app.toolbars["Toolbar"].buttons["Done"]
        doneButton.tap()
        
        let expiryTextField = collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Expiry"]/*[[".cells",".textFields[\"MM\/YY\"]",".textFields[\"Expiry\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        expiryTextField.tap()
        expiryTextField.tap()
        app/*@START_MENU_TOKEN@*/.pickerWheels["01"]/*[[".pickers.pickerWheels[\"01\"]",".pickerWheels[\"01\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        app/*@START_MENU_TOKEN@*/.pickerWheels["2021"]/*[[".pickers.pickerWheels[\"2021\"]",".pickerWheels[\"2021\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        doneButton.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["Name on card"]/*[[".cells",".textFields[\"J Appleseed\"]",".textFields[\"Name on card\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["done"]/*[[".keyboards",".buttons[\"done\"]",".buttons[\"Done\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Add"].tap()
        app.buttons["I accept"].tap()
        app.navigationBars["binkapp.PaymentCardDetailView"].buttons["Back"].tap()
        
        let element = app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.swipeDown()
        element.tap()
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Not linked"]/*[[".cells.staticTexts[\"Not linked\"]",".staticTexts[\"Not linked\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
}
