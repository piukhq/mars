//
//  AutomatedTesting.swift
//  binkappUITests
//
//  Created by Sean Williams on 14/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import XCTest

class AutomatedTesting {
    enum EnvironmentType: String, CaseIterable {
        case dev = "api.dev.gb.bink.com"
        case staging = "api.staging.gb.bink.com"
        case preprod = "api.preprod.gb.bink.com"
        case production = "api.gb.bink.com"
        
        var iOS13identifier: String {
            switch self {
            case .dev:
                return "Dev"
            case .staging:
                return "Staging"
            default:
                return "Dev"
            }
        }
    }
    
    let app = XCUIApplication()
    
    func logout() {
        app.buttons["Loyalty"].tap()
        app.navigationBars["binkapp.LoyaltyWalletView"].buttons["settings"].tap()
        app.tables.cells["Log out"].tap()
        app.buttons["Log out"].tap()
    }
    
    func loginIntoEnvironment(type: EnvironmentType) {
        if !app.buttons["Log in"].exists {
            logout()
        }
        
        app.scrollViews["Learning scrollview"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        if app.tables.cells["Environment Base URL"].exists {
            app.tables.cells["Environment Base URL"].tap()
            app.sheets.scrollViews.otherElements.buttons[type.iOS13identifier].tap()
        } else {
            // iOS 14 >
            app.buttons["Select Environment"].tap()
            app.buttons[type.rawValue].tap()
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
    }
}
