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
    static var sut = PreviousUpdatesViewModel()
    
    static let notes = """
{
        "releases": [
          {
            "release_title": "Update: v2.3.30 Date: 11/03/2023",
            "release_notes": [
              {
                "heading": "Features",
                "bullet_points": [
                  "What's New pop-up - See all the latest features and Retailers to your Bink app along with what is coming up!",
                  "Previous Updates History - keen to see what we have worked on in previous releases? look no further"
                ]
              },
              {
                "heading": "Bug Fixes",
                "bullet_points": [
                  "Issue where Surnames would overlap with card logos in your Payment Wallet",
                  "Minor visual tweaks to dark mode"
                ]
              },
              {
                "heading": "Retailers",
                "bullet_points": [
                  "Viator - Find thousands of experiences at your fingertip and get rewarded for doing them with Viator"
                ]
              }
            ]
          },
          {
            "release_title": "Update: v2.3.31 Date: 19/05/2023",
            "release_notes": [
              {
                "heading": "Features",
                "bullet_points": [
                  "Now even easier to add Custom Loyalty Cards, should you not be able to find the Retailer you are looking for in the search menu",
                  "Your What's New screen screen no longer disappears when you check out one of our new features",
                  "New Logo and tweaks to the colour scheme"
                ]
              },
              {
                "heading": "Bug Fixes",
                "bullet_points": [
                  "Fixed an issue where the Accept and Decline buttons were obscuring text when adding a new Payment card and viewing terms and conditions",
                  "Flashlight no longer falls off the screen when scanning a Loyalty card"
                ]
              }
            ]
          }
        ]
      }
"""
    
    override class func setUp() {
        super.setUp()
        
        let data = notes.data(using: .utf8)!
        let val = try! JSONDecoder().decode(ReleaseNotes.self, from: data)
        Self.sut.items = val.releases!
            
    }

    func test_releaseCorrectCount() {
        XCTAssertTrue(Self.sut.items.count == 2)
    }
    
    func test_releasesHaveCorrectTitles() {
        XCTAssertEqual(Self.sut.items[0].releaseTitle, "Update: v2.3.30 Date: 11/03/2023")
        
        XCTAssertEqual(Self.sut.items[1].releaseTitle, "Update: v2.3.31 Date: 19/05/2023")
    }
    
    func test_releasesNotesAreValid() {
        var notes = Self.sut.items[0].releaseNotes![0]
        XCTAssertEqual(notes.heading, "Features")
        XCTAssertTrue(notes.bulletPoints!.count > 0)
        
        notes = Self.sut.items[1].releaseNotes![1]
        XCTAssertEqual(notes.heading, "Bug Fixes")
        XCTAssertTrue(notes.bulletPoints!.count > 0)
    }
}
