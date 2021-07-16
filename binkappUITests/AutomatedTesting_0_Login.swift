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
        if !app.buttons["Log in"].exists {
            AutomatedTesting.logout()
        }
        XCTAssertTrue(app.buttons["Log in"].waitForExistence(timeout: 20), "Login button does not exist")
    }
    
    func test2_loginWithEmailAndPassword() {
        AutomatedTesting.loginIntoEnvironment(type: .dev)
        
        let paymentTabBarButton = app.buttons["Payment"]
        XCTAssertTrue(paymentTabBarButton.waitForExistence(timeout: 30))
    }
}
