//
//  DateManagerTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 02/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp
// swiftlint:disable all

final class DateManagerTests: XCTestCase {
    static var dateManager = DateManager()
    
    override class func setUp() {
        super.setUp()
        
        dateManager.reset()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let date = dateFormatter.date(from: "2/11/2022 14:30")
        dateManager.adjustDate(date!)
    }
    
    func test_returnsCorrectHour() throws {
        XCTAssertTrue(Self.dateManager.currentHour == 14)
    }
    
    func test_returnsCorrectToday() throws {
        XCTAssertTrue(Self.dateManager.today() == 4)
    }
    
    func test_returnsCorrectTomorrow() throws {
        XCTAssertTrue(Self.dateManager.tomorrow() == 5)
    }
    
    func test_returnsCorrectWeekdayAsString() throws {
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 1) == "Sunday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 2) == "Monday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 3) == "Tuesday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 4) == "Wednesday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 5) == "Thursday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 6) == "Friday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 7) == "Saturday")
        XCTAssertTrue(Self.dateManager.dayOfTheWeek(id: 8) == "")
    }
}
