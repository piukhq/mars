//
//  SettingsFactoryTests.swift
//  binkappTests
//
//  Created by Paul Tiriteu on 07/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class SettingsFactoryTests: XCTestCase {
    func test_sectionsCount_isCorrect() {
        let factory = SettingsFactory(router: MainScreenRouter(delegate: self))
        #if DEBUG
        XCTAssertEqual(factory.sectionData().count, 5)
        #else
        XCTAssertEqual(factory.sectionData().count, 4)
        #endif
    }
}

extension SettingsFactoryTests: MainScreenRouterDelegate {
    func router(_ router: MainScreenRouter, didLogin: Bool) {}
}
