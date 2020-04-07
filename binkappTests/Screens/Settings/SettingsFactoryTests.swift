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
    func test_numberOfRows() {
        let router = MainScreenRouter(delegate: self)
        let factory = SettingsFactory(router: router)
        XCTAssertEqual(factory.sectionData().count, 9)
    }
}

extension SettingsFactoryTests: MainScreenRouterDelegate {
    func router(_ router: MainScreenRouter, didLogin: Bool) {}
}
