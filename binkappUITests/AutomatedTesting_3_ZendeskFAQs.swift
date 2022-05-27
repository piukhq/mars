//
//  AutomatedTesting_3_ZendeskFAQs.swift
//  binkappUITests
//
//  Created by Sean Williams on 07/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_3_ZendeskFAQs: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
    }
    
    func test_0_zendesk_aboutBink_article_exists() {
        AutomatedTesting.loginIntoEnvironment(type: .production)
        
        sleep(30)
        
        app.buttons["settings"].tap()
        app.tables.cells["FAQs"].tap()
        
        sleep(10)
        
        XCTAssertTrue(app.staticTexts["Bink Help"].waitForExistence(timeout: 20))
    }
}
