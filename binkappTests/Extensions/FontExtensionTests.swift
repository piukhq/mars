//
//  FontExtensionTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 21/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
import SwiftUI
@testable import binkapp

class FontExtensionTests: XCTestCase {
    func test_nunitoSemiBold() throws {
        let font = Font.nunitoSemiBold(12)
        XCTAssertNotNil(font)
    }
    
    func test_nunitoBold() throws {
        let font = Font.nunitoBold(12)
        XCTAssertNotNil(font)
    }
    
    func test_nunitoExtraBold() throws {
        let font = Font.nunitoExtraBold(12)
        XCTAssertNotNil(font)
    }
    
    func test_nunitoSans() throws {
        let font = Font.nunitoSans(12)
        XCTAssertNotNil(font)
    }
}
