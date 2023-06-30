//
//  GeoLocationModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 07/07/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class GeoLocationModelTests: XCTestCase {

    let openHours = OpenHours(mon: [["6:00", "24:00"]], tue: [["7:00", "21:00"]], wed: [["6:00", "24:00"]], thu: [["6:00", "24:00"]], fri: [["6:00", "24:00"]], sat: [["6:00", "24:00"]], sun: [["6:00", "24:00"]])
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
    
    let badJson = """
                {
                    "type": "FeatureCollection",
                    "features": [{
                        "properties": {
                            "location_name": "Tesco Express",
                            "latitude": 52.097961,
                            "longitude": -0.528923,
                            "street_address": "14 Cause End Road",
                            "city": "Bedford",
                            "region": "Bedfordshire",
                            "postal_code": "MK43 9DA",
                            "phone_number": true,
                            "open_hours": ""
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [
                                "-0.528923",
                                "52.097961"
                            ]
                        }
                    }]
                }
    """
    
    func test_shouldParseJson() throws {
        let jsonData = goodJson.data(using: .utf8)!
        let response = try! JSONDecoder().decode(GeoModel.self, from: jsonData)
        XCTAssertNotNil(response)
    }
    
    func test_shouldFailToParseJson() throws {
        let jsonData = badJson.data(using: .utf8)
        let response = try? JSONDecoder().decode(GeoModel.self, from: jsonData ?? Data())
        XCTAssertNil(response)
    }
    
    func test_openingTimesAreCorrect() throws {
        let openTimes = openHours.openingTimes(for: 0)
        
        XCTAssertTrue(openTimes?.opening == "6:00")
        XCTAssertTrue(openTimes?.closing == "24:00")
    }
    
    func test_openingTimesForNextOpenDayAreCorrect() throws {
        let openTimes = openHours.openingTimesForNextOpenDay(from: 3)
        
        print(openTimes)
        
        XCTAssertTrue(openTimes?.opening == "7:00")
        XCTAssertTrue(openTimes?.closing == "21:00")
    }
}
