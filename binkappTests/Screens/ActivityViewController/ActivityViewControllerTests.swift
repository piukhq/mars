//
//  ActivityViewControllerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 09/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class ActivityViewControllerTests: XCTestCase {
    func test_isDataValid() throws {
        let sut = ActivityViewController(activityItemMetadata: LinkMetadataManager(title: "Title", url: URL(fileURLWithPath: "somePath")))
        
        XCTAssertNotNil(sut.activityItemMetadata)
        XCTAssertNotNil(sut.activityItemMetadata.linkMetadata)
        XCTAssertEqual(sut.activityItemMetadata.title, "Title")
        XCTAssertEqual(sut.activityItemMetadata.url.path, "/somePath")
    }
}
