//
//  WalletRefreshManagerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 18/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class WalletRefreshManagerTests: XCTestCase {
    func test_TimeIntervalRawValues() throws {
        XCTAssertTrue(WalletRefreshManager.RefreshInterval.twoMinutes.readableValue == "two minutes")
        XCTAssertTrue(WalletRefreshManager.RefreshInterval.oneHour.readableValue == "one hour")
        XCTAssertTrue(WalletRefreshManager.RefreshInterval.twoHours.readableValue == "two hours")
        XCTAssertTrue(WalletRefreshManager.RefreshInterval.twelveHours.readableValue == "twelve hours")
        XCTAssertTrue(WalletRefreshManager.RefreshInterval.threeDays.readableValue == "three days")
    }
    
    func test_RefreshManagerShouldBeActive() throws {
        let refreshManager = WalletRefreshManager()
        refreshManager.start()
        XCTAssertTrue(refreshManager.isActive == true)
    }
    
    func test_RefreshManagerCanResetAccounts() throws {
        let refreshManager = WalletRefreshManager()
        refreshManager.start()
 
        let exp = expectation(description: "Wait for trigger to be called after delay")
        let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(refreshManager.canRefreshAccounts == true)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_RefreshManagerCanRefreshPlans() throws {
        let refreshManager = WalletRefreshManager()
        refreshManager.start()
        
        let exp = expectation(description: "Wait for trigger to be called after delay")
        let result = XCTWaiter.wait(for: [exp], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(refreshManager.canRefreshPlans == true)
        } else {
            XCTFail("Delay interrupted")
        }
    }
}
