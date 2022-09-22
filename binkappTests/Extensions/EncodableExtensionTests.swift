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
    func test_modelIsEncoded_asDictionary() throws {
        let dictionary = try! MagicLinkRequestModel(email: "email@email.com").asDictionary()
        
        XCTAssertEqual(dictionary["email"] as! String, "email@email.com")
        XCTAssertEqual(dictionary["locale"] as! String, "en_GB")
    }
}
