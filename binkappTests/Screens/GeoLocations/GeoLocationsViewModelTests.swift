//
//  GeoLocationsViewModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class GeoLocationsViewModelTests: XCTestCase {
    static var sut = GeoLocationViewModel(companyName: "Tesco")
    
    override func setUp() {
        super.setUp()
        let goodJson = """
            {
                "type": "FeatureCollection",
                "features": [{
                    "type": "Feature",
                    "properties": {
                        "location_name": "Tesco Express",
                        "latitude": "52.097961",
                        "longitude": "-0.528923",
                        "street_address": "14 Cause End Road",
                        "city": "Bedford",
                        "region": "Bedfordshire",
                        "postal_code": "MK43 9DA",
                        "phone_number": "4.43456E+11",
                        "open_hours": ""
                    },
                    "geometry": {
                        "type": "Point",
                        "coordinates": [
                            -0.528923,
                            52.097961
                        ]
                    }
                }]
            }
        """
        Cache.geoLocationsDataCache.setObject(goodJson.data(using: .utf8)! as NSData, forKey: "tesco.geojson".toNSString())
    }
    
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
