//
//  AutomatedTesting_0_Login.swift
//  binkappUITests 
//
//  Created by Sean Williams on 27/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_0_Login: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
    }
    
    
    func test0_loginScreenOnAppLaunch_exists() {
        XCTAssertTrue(app.buttons["Log in"].waitForExistence(timeout: 20), "Login button does not exist")
    }
    
    func test2_loginWithEmailAndPassword() {
        app.scrollViews["Learning scrollview"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        if app.tables.cells["Environment Base URL"].exists {
            app.tables.cells["Environment Base URL"].tap()
            app.sheets.scrollViews.otherElements.buttons["Dev"].tap()
        } else {
            app.buttons["Select Environment"].tap()
            app.buttons["api.gb.bink.com"].tap()
            app.scrollViews["Learning scrollview"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
            app.buttons["Select Environment"].tap()
            app.buttons["api.dev.gb.bink.com"].tap()
        }
        app.buttons["Log in"].tap()
        
        let emailTextfield = app.textFields["Enter email address"]
        emailTextfield.tap()
        emailTextfield.typeText("binklogin@binktest.com")
        
        let passwordtextfield = app.secureTextFields["Enter password"]
        passwordtextfield.tap()
        passwordtextfield.typeText("Binklogin123")
        app.buttons["done"].tap()
        app.buttons["Continue"].tap()
        
        let paymentTabBarButton = app.buttons["Payment"]
        XCTAssertTrue(paymentTabBarButton.waitForExistence(timeout: 30))
    }
}
