//
//  ReleaseUpdatesTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 07/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class ReleaseUpdatesTests: XCTestCase {
    var sut = PreviousUpdatesViewModel()

    func test_releaseCorrectCount() {
        XCTAssertTrue(sut.items.count == 2)
    }
    
    func test_releasesHaveCorrectTitles() {
        XCTAssertEqual(sut.items[0].releaseTitle, "Update: v2.3.29 Date: 6/03/2023")
        
        XCTAssertEqual(sut.items[1].releaseTitle, "Update: v2.3.28 Date: 27/02/2023")
    }
    
    func test_releasesNotesAreValid() {
        var notes = sut.items[0].releaseNotes![0]
        XCTAssertEqual(notes.heading, "Features")
        XCTAssertTrue(notes.bulletPoints!.count > 0)
        
        notes = sut.items[1].releaseNotes![1]
        XCTAssertEqual(notes.heading, "Retailers")
        XCTAssertTrue(notes.bulletPoints!.count > 0)
    }
}
