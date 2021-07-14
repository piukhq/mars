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
        AutomatedTesting().loginIntoEnvironment(type: .production)
        
        sleep(10)
        
        app.navigationBars["binkapp.LoyaltyWalletView"].buttons["settings"].tap()
        app.tables.cells["FAQs"].tap()
        
        sleep(10)
        
        app.tables.staticTexts["Does Bink cost anything?"].tap()
        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["Does Bink cost anything?"].waitForExistence(timeout: 20))
    }
    
//    func test_1_zendesk_GDPR_article_exists() {
//        app.tables.staticTexts["What is GDPR? "].tap()
//        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["What is GDPR?"].waitForExistence(timeout: 3))
//    }
//    
//    func test_2_zendesk_howToLinkWithBink_article_exists() {
//        app.tables.staticTexts["How do I download the Bink app?  "].tap()
//        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["How do I download the Bink app?"].waitForExistence(timeout: 3))
//    }
//    
//    func test_3_zendesk_managingYourBinkWallet_article_exists() {
//        app.tables.staticTexts["Why is my payment card stuck in Pending?"].tap()
//        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["Why is my payment card stuck in Pending?"].waitForExistence(timeout: 3))
//    }
//
//    func test_4_zendesk_managingYourAccount_article_exists() {
//        app.tables.staticTexts["How do I change the marketing messages I receive? "].tap()
//        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["How do I change the marketing messages I receive?"].waitForExistence(timeout: 3))
//    }
//
//    func test_5_zendesk_binkAndBeyond_article_exists() {
//        app.tables.staticTexts["Why can't I link my card?"].tap()
//        XCTAssertTrue(app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.staticTexts["Why can't I link my card?"].waitForExistence(timeout: 3))
//    }
}
