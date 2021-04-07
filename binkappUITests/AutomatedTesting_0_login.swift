//
//  binkappUITests.swift
//  binkappUITests
//
//  Created by Sean Williams on 27/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_0_login: XCTestCase {
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
}
