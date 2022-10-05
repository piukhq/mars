//
//  GeoLocationsViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class GeoLocationsViewModelTests: XCTestCase {
    static var sut = GeoLocationViewModel(companyName: "Tesco")


    func test_titleIsCorrect() throws {
        XCTAssertEqual(Self.sut.title, "Tesco Locations")
    }
    
    func test_hasFeatures() throws {
        Self.sut.parseGeoJson()
        
        XCTAssertTrue(!Self.sut.features.isEmpty)
    }
    
    func test_hasAnnotations() throws {
        Self.sut.parseGeoJson()
        
        XCTAssertTrue(!Self.sut.annotations.isEmpty)
    }
}
