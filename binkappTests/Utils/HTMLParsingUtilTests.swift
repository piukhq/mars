//
//  HTMLParsingUtilTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 01/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

final class HTMLParsingUtilTests: XCTestCase {

    func test_getCorrectClosingTagsString() throws {
        var header = HTMLParsingUtil.HTMLHeaderTag.h1
        XCTAssertTrue(header.closingTag == "</h1>")
        
        header = HTMLParsingUtil.HTMLHeaderTag.h2
        XCTAssertTrue(header.closingTag == "</h2>")
        
        header = HTMLParsingUtil.HTMLHeaderTag.h3
        XCTAssertTrue(header.closingTag == "</h3>")
    }
    
    func test_getCorrectFontForHeadline() throws {
        var header = HTMLParsingUtil.HTMLHeaderTag.h1
        XCTAssertTrue(header.font == .headline)
        
        header = HTMLParsingUtil.HTMLHeaderTag.h2
        XCTAssertTrue(header.font == .subtitle)
        
        header = HTMLParsingUtil.HTMLHeaderTag.h3
        XCTAssertTrue(header.font == .linkTextButtonNormal)
    }
    
    func test_returnsCorrectTextFromHtml() async throws {        
        let url = Bundle.main.url(forResource: "htmlTest", withExtension: "html")!
        let text = NSAttributedString(attributedString:  HTMLParsingUtil.makeAttributedStringFromHTML(url: url)!)
        
        XCTAssertTrue(text.string == "Heading 1 \nHeading 2\nHeading 3\n\n")
        
    }
}
