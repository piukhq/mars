//
//  AppVersionTests.swift
//  binkappTests
//
//  Created by Nick Farrant on 11/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class AppVersionTests: XCTestCase {
    func test_appVersion_canInitialise_withCorrectFullVersionString() {
        let versionString = "1.2.3"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertNotNil(appVersion)
    }
    
    func test_appVersion_returnsComponentsCorrectly_majorToPatch() {
        let versionString = "1.2.3"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertEqual(appVersion?.major, 1)
        XCTAssertEqual(appVersion?.minor, 2)
        XCTAssertEqual(appVersion?.patch, 3)
    }
    
    func test_appVersion_returnsComponentsCorrectly_majorToMinor() {
        let versionString = "1.2"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertEqual(appVersion?.major, 1)
        XCTAssertEqual(appVersion?.minor, 2)
        XCTAssertNil(appVersion?.patch)
    }
    
    func test_appVersion_returnsComponentsCorrectly_majorOnly() {
        let versionString = "1"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertEqual(appVersion?.major, 1)
        XCTAssertNil(appVersion?.minor)
        XCTAssertNil(appVersion?.patch)
    }
    
    func test_appVersion_returnsComponentsCorrectly_withMalformedVersionString() {
        let versionString = "1.a.b"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertEqual(appVersion?.major, 1)
        XCTAssertNil(appVersion?.minor)
        XCTAssertNil(appVersion?.patch)
    }
    
    func test_appVersion_returnsComponentsCorrectly_withLongVersionString() {
        let versionString = "1.2.3.4"
        let appVersion = AppVersion(versionString: versionString)
        XCTAssertEqual(appVersion?.versionString, "1.2.3")
    }
    
    func test_isMoreRecentThanVersion_returnsCorrectly() {
        let currentAppVersion = AppVersion(versionString: "1.2.3")!
        var recommendedLiveAppVersion = AppVersion(versionString: "1.2.4")!
        XCTAssertTrue(recommendedLiveAppVersion.isMoreRecentThanVersion(currentAppVersion))
        
        recommendedLiveAppVersion = AppVersion(versionString: "1.2.1")!
        XCTAssertFalse(recommendedLiveAppVersion.isMoreRecentThanVersion(currentAppVersion))
    }
}
