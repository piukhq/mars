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
    
    func test_0_zendesk_isSuccessful() {
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.icons["Bink β"]/*[[".otherElements[\"Home screen icons\"]",".icons.icons[\"Bink β\"]",".icons[\"Bink β\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["binkapp.LoyaltyWalletView"].buttons["settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Frequently asked questions"]/*[[".cells.staticTexts[\"Frequently asked questions\"]",".staticTexts[\"Frequently asked questions\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Does Bink cost anything?"]/*[[".cells[\"Article: Does Bink cost anything?.\"]",".staticTexts[\"ZDKarticleTitleStandardFont\"]",".staticTexts[\"Does Bink cost anything?\"]",".staticTexts[\"ZDKarticleTitle\"]"],[[[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Does Bink cost anything?"].buttons["Back"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["What is GDPR? "]/*[[".cells[\"Article: What is GDPR? .\"]",".staticTexts[\"ZDKarticleTitleStandardFont\"]",".staticTexts[\"What is GDPR? \"]",".staticTexts[\"ZDKarticleTitle\"]"],[[[-1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let webViewsQuery = app.scrollViews["ZDKarticleViewScrollView"].otherElements.webViews.webViews.webViews
        let whatIsGdprStaticText = webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["What is GDPR?"]/*[[".otherElements[\"What is GDPR?\"].staticTexts[\"What is GDPR?\"]",".staticTexts[\"What is GDPR?\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        whatIsGdprStaticText.tap()
        webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["GDPR expands the privacy rights granted to data subjects (EU/EEA individuals) and places greater obligations on organisations who handle the personal data of those individuals, wherever those organisations are based."]/*[[".staticTexts[\"GDPR expands the privacy rights granted to data subjects (EU\/EEA individuals) and places greater obligations on organisations wh\"]",".staticTexts[\"GDPR expands the privacy rights granted to data subjects (EU\/EEA individuals) and places greater obligations on organisations who handle the personal data of those individuals, wherever those organisations are based.\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        whatIsGdprStaticText.tap()
        
    }
}
