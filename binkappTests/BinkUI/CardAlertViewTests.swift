//
//  CardAlertViewTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class CardAlertViewTests: XCTestCase {

    func test_CorrectpropertiesForType() throws {
        let view = CardAlertView()
        view.configureForType(.loyaltyLogIn, action: {})
        XCTAssertTrue(view.getAlertLabel().text == "Log in")
        XCTAssertTrue(view.getAlertLabel().font == .alertText)
        XCTAssertTrue(view.getAlertLabel().textColor == .black)
        
        view.configureForType(.paymentExpired, action: {})
        XCTAssertTrue(view.getAlertLabel().text == "Expired")
        XCTAssertTrue(view.getAlertLabel().font == .alertText)
        XCTAssertTrue(view.getAlertLabel().textColor == .black)
        
        XCTAssertTrue(!view.gestureRecognizers!.isEmpty)
    }
}
