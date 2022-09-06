//
//  MainTabBarViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class MainTabBarViewModelTests: XCTestCase {
    static var model = MainTabBarViewModel()
    
    func test_viewControllersCount() throws {
        XCTAssertEqual(Self.model.viewControllers.count, 3)
    }
    
    func test_loyaltyButtonBarItem_shouldBeValid() throws {
        let vc = Self.model.viewControllers[0] as! PortraitNavigationController
        XCTAssertNotNil(vc.tabBarItem)
        XCTAssertEqual(vc.tabBarItem.title, "Loyalty")
    }
    
    func test_addButtonBarItem_shouldBeValid() throws {
        let vc = Self.model.viewControllers[1] as! BrowseBrandsViewController
        XCTAssertNotNil(vc.tabBarItem)
        XCTAssertEqual(vc.tabBarItem.accessibilityIdentifier, "Browse brands")
    }
    
    func test_paymentButtonBarItem_shouldBeValid() throws {
        let vc = Self.model.viewControllers[2] as! PortraitNavigationController
        XCTAssertNotNil(vc.tabBarItem)
        XCTAssertEqual(vc.tabBarItem.title, "Payment")
    }
    
    func test_correctlyNavigatesToBrandsVC() throws {
        Self.model.toBrowseBrandsScreen()

        XCTAssertTrue(Current.navigate.currentViewController!.isKind(of: BrowseBrandsViewController.self))
    }
}
