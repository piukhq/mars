//
//  DateExtensionTests.swift
//  binkappTests
//
//  Created by Sean Williams on 12/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

class DateExtensionTests: XCTestCase {
    let formatter = DateFormatter()
    var date: Date!
    var lastYear: Date!
    
    override func setUp() {
        super.setUp()
        let currentIsoDate = "2020-11-12T10:44:00+0000"
        let lastYearIsoDate = "2019-11-12T10:44:00+0000"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        date = formatter.date(from: currentIsoDate)
        lastYear = formatter.date(from: lastYearIsoDate)
    }
    
    func test_date_format_enum() {
        XCTAssertEqual(DateFormat.dayMonthYear.rawValue, "dd MMMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear.rawValue, "dd MMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYearWithSlash.rawValue, "dd/MM/YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear24HourSecond.rawValue, "dd MMM yyyy HH:mm:ss")
    }
    
    func test_getFormattedString_output_format() {
        XCTAssertEqual(date?.getFormattedString(format: .dayMonthYear), "12 November 2020")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYear), "12 Nov 2020")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYear24HourSecond), "12 Nov 2020 10:44:00")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYearWithSlash), "12/11/2020")
    }
    
    func test_make_date_from_components() {
        let expiryDate = Date.makeDate(year: 2020, month: 11, day: 12, hr: 10, min: 44, sec: 00)
        XCTAssertEqual(expiryDate, date)
    }
    
    func test_date_isLaterThan_another_date() {
        XCTAssertTrue(lastYear?.isLaterThan(date: date, toGranularity: .day) ?? false)
        XCTAssertTrue(lastYear?.isLaterThan(date: date, toGranularity: .month) ?? false)
        XCTAssertTrue(lastYear?.isLaterThan(date: date, toGranularity: .year) ?? false)
    }
    
    func test_monthIsExpired_false() {
        XCTAssertFalse(lastYear.monthIsExpired)
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
        XCTAssertTrue(Date.hasElapsed(days: 365, since: lastYear))
    }
}
