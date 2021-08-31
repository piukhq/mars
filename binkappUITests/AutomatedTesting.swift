//
//  AutomatedTesting.swift
//  binkappUITests
//
//  Created by Sean Williams on 14/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation
import XCTest

enum AutomatedTesting {
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
    
    enum PullToRefreshID: String {
        case iceland = "Iceland"
        case bAndQ = "B&Q"
        case mastercard = "B Testerson"
    }
    
    static let app = XCUIApplication()
    
    static func logout() {
        if !app.buttons["Continue with Email"].exists {
            app.buttons["Loyalty"].tap()
            app.buttons["settings"].tap()
            app.tables.cells["Log out"].tap()
            app.buttons["Log out"].tap()
        }
    }
    
    static func loginIntoEnvironment(type: EnvironmentType) {
        logout()
        
        sleep(30)
        
        app.scrollViews["Learning scrollview"].tap(withNumberOfTaps: 3, numberOfTouches: 1)
        if app.tables.cells["Environment Base URL"].exists {
            app.tables.cells["Environment Base URL"].tap()
            app.sheets.scrollViews.otherElements.buttons[type.iOS13identifier].tap()
        } else {
            // iOS 14 >
            app.buttons["Select Environment"].tap()
            app.buttons[type.rawValue].tap()
        }
        
        sleep(5)
        
        if !app.buttons["Continue with Email"].exists {
            app.buttons["Back"].tap()
        }
        app.buttons["Continue with Email"].tap()
        app.buttons["Use a password"].tap()
        
        let emailTextfield = app.textFields["Enter email address"]
        emailTextfield.tap()
        emailTextfield.typeText("binklogin@binktest.com")
        
        let passwordtextfield = app.secureTextFields["Enter password"]
        passwordtextfield.tap()
        passwordtextfield.typeText("Binklogin123")
        app.buttons["done"].tap()
        app.buttons["Continue"].tap()
    }
    
    static func pullToRefresh(from identifier: PullToRefreshID) {
        let cell = app.collectionViews.cells[identifier.rawValue]
        let start = cell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = cell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 50))
        start.press(forDuration: 0, thenDragTo: finish)
    }
}
