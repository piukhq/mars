//
//  DateExtensionTests.swift
//  binkappTests
//
//  Created by Sean Williams on 12/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

@available(iOS 13.0, *)
class DateExtensionTests: XCTestCase {
    let formatter = DateFormatter()
    var currentDate: Date!
    var lastYear: Date!
    var oneDayAgo: Date!

    
    override func setUp() {
        super.setUp()
        currentDate = Date.makeDate(year: 2020, month: 11, day: 12, hr: 10, min: 44, sec: 00)
        lastYear = Date.makeDate(year: 2019, month: 11, day: 12, hr: 10, min: 44, sec: 00)
        oneDayAgo = Date().advanced(by: -86400)
    }
    
    func test_date_format_enum() {
        XCTAssertEqual(DateFormat.dayMonthYear.rawValue, "dd MMMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear.rawValue, "dd MMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYearWithSlash.rawValue, "dd/MM/YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear24HourSecond.rawValue, "dd MMM yyyy HH:mm:ss")
    }
    
    func test_timeAgoString() {
        XCTAssertEqual(oneDayAgo.timeAgoString(), "1 day")
        
        let threeDaysAgo = Date().addingTimeInterval( -259200)
        XCTAssertEqual(threeDaysAgo.timeAgoString(), "3 days")
        
        let oneWeekAgo = Date().addingTimeInterval( -604800)
        XCTAssertEqual(oneWeekAgo.timeAgoString(), "7 days")
    }
    
    func test_getFormattedString_output_format() {
        XCTAssertEqual(currentDate?.getFormattedString(format: .dayMonthYear), "12 November 2020")
        XCTAssertEqual(currentDate?.getFormattedString(format: .dayShortMonthYear), "12 Nov 2020")
        XCTAssertEqual(currentDate?.getFormattedString(format: .dayShortMonthYear24HourSecond), "12 Nov 2020 10:44:00")
        XCTAssertEqual(currentDate?.getFormattedString(format: .dayShortMonthYearWithSlash), "12/11/2020") 
    }
    
    func test_make_date_from_components() {
        let expiryDate = Date.makeDate(year: 2020, month: 11, day: 12, hr: 10, min: 44, sec: 00)
        XCTAssertEqual(expiryDate, currentDate)
    }
    
    func test_date_isBefore_another_date() {
        XCTAssertTrue(lastYear?.isBefore(date: currentDate, toGranularity: .day) ?? false)
        XCTAssertTrue(lastYear?.isBefore(date: currentDate, toGranularity: .month) ?? false)
        XCTAssertTrue(lastYear?.isBefore(date: currentDate, toGranularity: .year) ?? false)
        XCTAssertTrue(oneDayAgo.isBefore(date: Date(), toGranularity: .day))
        XCTAssertFalse(Date().addingTimeInterval(86400).isBefore(date: Date(), toGranularity: .day))
    }
    
    func test_monthHasNotExpired() {
        XCTAssertFalse(lastYear.monthHasNotExpired)
        XCTAssertFalse(Date().addingTimeInterval((-86400 * 33)).monthHasNotExpired)
        XCTAssertTrue(Date().monthHasNotExpired)
    }
    
    func test_numberOfSecondsInDays() {
        XCTAssertEqual(Date.numberOfSecondsIn(days: 1), 86400)
        XCTAssertEqual(Date.numberOfSecondsIn(days: 2), 172800)
        XCTAssertEqual(Date.numberOfSecondsIn(days: 4), 345600)
        XCTAssertEqual(Date.numberOfSecondsIn(days: 8), 691200)
    }
    
    func test_numberOfSecondsInHours() {
        XCTAssertEqual(Date.numberOfSecondsIn(hours: 1), 3600)
        XCTAssertEqual(Date.numberOfSecondsIn(hours: 2), 7200)
        XCTAssertEqual(Date.numberOfSecondsIn(hours: 4), 14400)
        XCTAssertEqual(Date.numberOfSecondsIn(hours: 8), 28800)
    }
    
    func test_numberOfSecondsInMinutes() {
        XCTAssertEqual(Date.numberOfSecondsIn(minutes: 1), 60)
        XCTAssertEqual(Date.numberOfSecondsIn(minutes: 2), 120)
        XCTAssertEqual(Date.numberOfSecondsIn(minutes: 4), 240)
        XCTAssertEqual(Date.numberOfSecondsIn(minutes: 8), 480)
    }
    
    func test_days_hasElapsed() {
        XCTAssertFalse(Date.hasElapsed(days: 2, since: oneDayAgo))
        XCTAssertTrue(Date.hasElapsed(days: 1, since: oneDayAgo))
    }
    
    func test_hours_hasElapsed() {
        XCTAssertFalse(Date.hasElapsed(hours: 25, since: oneDayAgo))
        XCTAssertTrue(Date.hasElapsed(hours: 24, since: oneDayAgo))
    }
    
    func test_minutes_hasElapsed() {
        XCTAssertFalse(Date.hasElapsed(minutes: 1441, since: oneDayAgo))
        XCTAssertTrue(Date.hasElapsed(minutes: 1440, since: oneDayAgo))
    }
}
