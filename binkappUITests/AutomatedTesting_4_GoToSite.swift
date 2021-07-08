//
//  AutomatedTesting_4_GoToSite.swift
//  binkappUITests
//
//  Created by Sean Williams on 08/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_4_GoToSite: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
    }
    
    func test_burgerKing_goToSite_loadsWebpage_successfully() {
        app.buttons["Browse brands"].tap()
        app.tables.cells["Burger King"].tap()
        app.buttons["Bink info button"].tap()

        app.buttons["Go to site"].tap()
        
        let viewMenuButton = app.webViews.webViews.webViews/*@START_MENU_TOKEN@*/.buttons["View Menu"]/*[[".otherElements[\"Burger King\"]",".otherElements[\"main\"]",".otherElements[\"alert\"]",".links[\"View Menu\"].buttons[\"View Menu\"]",".buttons[\"View Menu\"]"],[[[-1,4],[-1,3],[-1,2,3],[-1,1,2],[-1,0,1]],[[-1,4],[-1,3],[-1,2,3],[-1,1,2]],[[-1,4],[-1,3],[-1,2,3]],[[-1,4],[-1,3]]],[0]]@END_MENU_TOKEN@*/
        viewMenuButton.swipeUp()
    }
}
