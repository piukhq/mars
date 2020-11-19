//
//  SecureUtilityTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 04/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class SecureUtilityTests: XCTestCase {
    func test_md5() {
        let stringToHash = "This is an md5 hashing test"
        let expectedHash = "cee1ac6a0563980b32124db54cb53d7a"
        let actualHash = stringToHash.md5
        XCTAssertEqual(expectedHash, actualHash)
    }

    func test_sha512() {
        let stringToHash = "This is a sha512 hashing test"
        let expectedHash = "52acfe076e0f8b1d427842220d353a4f48d0e38c8c4802242478e5b7ffe4de4028056304a56ad64e83996eac09b345058172607048fec27e315b1350c3cca9d0"
        let actualHash = stringToHash.sha512
        XCTAssertEqual(expectedHash, actualHash)
    }
}
