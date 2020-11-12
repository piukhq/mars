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
    
    override class func setUp() {
        super.setUp()
    }
    
    func test_date_format_enum() {
        XCTAssertEqual(DateFormat.dayMonthYear.rawValue, "dd MMMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear.rawValue, "dd MMM YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYearWithSlash.rawValue, "dd/MM/YYYY")
        XCTAssertEqual(DateFormat.dayShortMonthYear24HourSecond.rawValue, "dd MMM yyyy HH:mm:ss")
    }
    
    func test_getFormattedString_output_format() {
        let isoDate = "2020-11-12T10:44:00+0000"
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = formatter.date(from: isoDate)
        
        XCTAssertEqual(date?.getFormattedString(format: .dayMonthYear), "12 November 2020")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYear), "12 Nov 2020")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYear24HourSecond), "12 Nov 2020 10:44:00")
        XCTAssertEqual(date?.getFormattedString(format: .dayShortMonthYearWithSlash), "12/11/2020")
    }
    
    
}
