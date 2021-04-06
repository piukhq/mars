//
//  binkappUITests.swift
//  binkappUITests
//
//  Created by Sean Williams on 27/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest

class binkappUITests: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["enable-testing"]
        app.launch()
    }
    
    func test0_loginScreenOnAppLaunch_exists() {
        let buttonsQuery = app.buttons
        XCTAssertTrue(buttonsQuery.staticTexts["Log in with email"].waitForExistence(timeout: 20), "Login button does not exist")
    }
    
    func test1_loginWithEmailAndPassword() {
        app.buttons["Log in with email"].tap()
        
        let emailTextfield = app.textFields["Enter email address"]
        emailTextfield.tap()
        emailTextfield.typeText("binklogin@binktest.com")
        app.buttons["next"].tap()
        app.typeText("Binklogin123")
        app.buttons["done"].tap()
        app.buttons["Continue"].tap()
        
        let paymentTabBarButton = app.buttons["Payment"]
        XCTAssertTrue(paymentTabBarButton.waitForExistence(timeout: 30))
    }
    
    func test_addIcelandCard_isSuccessful() {
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
}
