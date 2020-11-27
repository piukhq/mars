//
//  binkappUITests.swift
//  binkappUITests
//
//  Created by Karl Sigiscar on 04/07/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import XCTest

class binkappUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
    }
    
    func test_loginScreenOnAppLaunch_exists() {
        let app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        let buttonsQuery = app.buttons
        XCTAssertTrue(buttonsQuery.staticTexts["Log in with email"].waitForExistence(timeout: 20), "Login button does not exist")
    }
    
    func test_loginWithEmailAndPassword() {
        let app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        
        let buttonsQuery = app.buttons
        let loginWithEmailButton = buttonsQuery.staticTexts["Log in with email"]
        loginWithEmailButton.tap()
        
        let emailTextfield = app.textFields.element(boundBy: 0)
        emailTextfield.tap()
        emailTextfield.typeText("binklogin@binktest.com")
        app.buttons["next"].tap()
        
        app.typeText("Binklogin123")
        app.buttons["done"].tap()
        app.buttons["Continue"].tap()
        
        let paymentTabBarButton = app.buttons["Payment"]

        XCTAssertTrue(paymentTabBarButton.waitForExistence(timeout: 30))
    }
}
