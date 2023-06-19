//
//  NewFeatureViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 13/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

import SwiftUI

// swiftlint:disable all

final class NewFeatureViewModelTests: XCTestCase {
    
    var sut: NewFeatureViewModel!
    
    let whatsNew = """
{
    "app_version": "2.3.0",
    "merchants": [
      {
        "id": "230",
        "description": [
          "Sign up to Tesco clubcard",
          "View your points"
        ]
      }
    ],
    "features": [
      {
        "id": "0",
        "title": "This is a new feature!",
        "description": [
          "This new feature is pretty cool and you should totally check it out."
        ],
        "screen": 4
      },
      {
        "id": "1",
        "title": "This is also a new feature!",
        "description": [
          "This new feature is even better, check it out."
        ],
        "screen": 5
      }
    ]
}
"""

    override func setUp() {
        super.setUp()
        
        let data = self.whatsNew.data(using: .utf8)!
        let val = try! JSONDecoder().decode(WhatsNewModel.self, from: data)
        print(val)
        if let feature = val.features!.first {
            self.sut = NewFeatureViewModel(feature: feature)
        }
    }

    func test_backgroundColourIsCorrect() {        
        XCTAssertEqual(sut.backgroundColor, Color.teal)
    }
    
    func test_textColourIsCorrect() {
        XCTAssertEqual(sut.textColor, Color.white)
    }
    
    func test_textsDescriptionIsCorrect() {
        XCTAssertEqual(sut.descriptionTexts!.first, "This new feature is pretty cool and you should totally check it out.")
    }
    
    func test_hasDeepLink() {
        XCTAssertEqual(sut.hasDeeplink, true)
    }
    
    func test_deepLinkScreenIsCorrect_loyaltyWallet() {
        sut.feature.screen = 0
        XCTAssertEqual(sut.deeplinkScreen, .loyaltyWallet)
    }
    
    func test_deepLinkScreenIsCorrect_paymentWallet() {
        sut.feature.screen = 1
        XCTAssertEqual(sut.deeplinkScreen, .paymentWallet)
    }

    func test_deepLinkScreenIsCorrect_browseBrands() {
        sut.feature.screen = 2
        XCTAssertEqual(sut.deeplinkScreen, .browseBrands)
    }
    
    func test_deepLinkScreenIsCorrect_settings() {
        sut.feature.screen = 3
        XCTAssertEqual(sut.deeplinkScreen, .settings)
    }
    
    func test_deepLinkScreenIsCorrect_lcd() {
        sut.feature.screen = 4
        XCTAssertEqual(sut.deeplinkScreen, .lcd)
    }
    
    func test_deepLinkScreenIsCorrect_barcodeView() {
        sut.feature.screen = 5
        XCTAssertEqual(sut.deeplinkScreen, .barcodeView)
    }
    
    
//    func test_navigatestoCorrectScreen_browseBrands() {
//        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 2.0)
//        sut.feature.screen = 2
//        sut.navigate(to: sut.deeplinkScreen)
//
//        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BrowseBrandsViewController.self))
//    }
//
//    func test_navigatestoCorrectScreen_lcd() {
//        _ = XCTWaiter.wait(for: [self.expectation(description: "Wait for network call closure to complete")], timeout: 2.0)
//
//        sut.feature.screen = 4
//        sut.navigate(to: sut.deeplinkScreen)
//
//        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: LoyaltyCardFullDetailsViewController.self))
//    }
    
    func test_navigatestoCorrectScreen_settings() {
        sut.feature.screen = 3
        sut.navigate(to: sut.deeplinkScreen)

        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: UIHostingController<SettingsView>.self))
    }
}
