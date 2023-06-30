//
//  WhatsNewViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 21/06/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

import SwiftUI

// swiftlint:disable all

final class WhatsNewViewModelTests: XCTestCase {

    var sut: WhatsNewViewModel!
    
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
        self.sut = WhatsNewViewModel(features: val.features, merchants: val.merchants)
    }
    
    func test_shouldHideWhatsNewScreen() {
        XCTAssertFalse(sut.shouldHideWhatsNewScreen)
    }
}
