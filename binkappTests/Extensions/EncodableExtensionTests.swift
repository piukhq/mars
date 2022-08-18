//
//  EncodableExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 18/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class EncodableExtensionTests: XCTestCase {
    func testExample() throws {
        let dic = try! MagicLinkRequestModel(email: "email@email.com").asDictionary()
        
        XCTAssertEqual(dic["email"] as! String, "email@email.com")
        XCTAssertEqual(dic["locale"] as! String, "en_GB")
    }
}
