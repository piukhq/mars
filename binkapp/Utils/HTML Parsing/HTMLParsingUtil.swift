//
//  HTMLParsingUtil.swift
//  binkapp
//
//  Created by Sean Williams on 01/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum HTMLParsingUtil {
    enum HTMLHeaderTag: String {
        case h1 = "<h1>"
        case h2 = "<h2>"
        case h3 = "<h3>"
        
        var closingTag: String {
            switch self {
            case .h1:
                return "</h1>"
            case .h2:
                return "</h2>"
            case .h3:
                return "</h3>"
            }
        }

        var font: UIFont {
            switch self {
            case .h1:
                return .headline
            case .h2:
                return .subtitle
            case .h3:
                return .linkTextButtonNormal
            }
        }
    }
    
    private static var hasFormattedHThreeSubtitles = false
    
    private static func configureAttributes(in htmlString: String, attributedString: NSMutableAttributedString, headerTag: HTMLHeaderTag, shouldConfigureBodyText: Bool = true) {
        if shouldConfigureBodyText {
            attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
        }
        
        var headerString = htmlString.slice(from: headerTag.rawValue, to: headerTag.closingTag)
        headerString = headerString?.replacingOccurrences(of: "    ", with: " ")
        headerString = headerString?.replacingOccurrences(of: "   ", with: " ")
        headerString = headerString?.replacingOccurrences(of: "&amp;", with: "&")
        headerString = headerString?.replacingOccurrences(of: "  ", with: " ")
        
        if let titleRange = attributedString.string.range(of: headerString ?? "") {
            let nsTitleRange = NSRange(titleRange, in: attributedString.string)
            attributedString.addAttribute(.font, value: headerTag.font, range: nsTitleRange)
        }
        
        configureLinks(in: htmlString, for: attributedString)
    }
    
    private static func configureLinks(in paragraph: String, for attributedString: NSMutableAttributedString) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
        let matches = detector.matches(in: paragraph, options: [], range: NSRange(location: 0, length: paragraph.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: paragraph) else { continue }
            var urlString = paragraph[range]
            let ranges = attributedString.string.ranges(of: String(urlString))
            
            for nsRange in ranges {
                if urlString.contains("@") {
                    urlString = "mailto:" + urlString
                } else {
                    if !urlString.hasPrefix("http") {
                        if urlString.hasPrefix("www") {
                            urlString = "https://" + urlString
                        } else {
                            urlString = "https://www." + urlString
                        }
                    }
                }
                
                if let URL = URL(string: String(urlString)) {
                    attributedString.addAttribute(.link, value: URL, range: nsRange)
                }
            }
        }
    }
    
    private static func buildParagraphForAttributedString(paragraph: String, configureAttributesInString: String, mutableAttributedString: inout NSMutableAttributedString, headerTag: HTMLHeaderTag) {
        let newLine = NSAttributedString(string: "\n")

        if let htmlData = NSString(string: paragraph).data(using: String.Encoding.unicode.rawValue) {
            if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                if !attributedString.string.isEmpty {
                    configureAttributes(in: configureAttributesInString, attributedString: attributedString, headerTag: headerTag)
                    
                    // If configuring H2 paragraphs, configure H3s
                    if headerTag == .h2 {
                        let paragraphsHThree = paragraph.components(separatedBy: HTMLHeaderTag.h3.rawValue)
                        paragraphsHThree.forEach {
                            configureAttributes(in: HTMLHeaderTag.h3.rawValue + $0, attributedString: attributedString, headerTag: .h3, shouldConfigureBodyText: false)
                            hasFormattedHThreeSubtitles = true
                        }
                    }
                    
                    if headerTag == .h1 {
                        mutableAttributedString = attributedString
                    } else {
                        mutableAttributedString.append(attributedString)
                    }
                    mutableAttributedString.append(newLine)
                }
            }
        }
    }

    private static func configureParagraphs(separatedByHeaderTags headerTag: HTMLHeaderTag, in section: String, mutableAttributedString: inout NSMutableAttributedString) {
        var paragraphs = section.components(separatedBy: headerTag.rawValue)
        if headerTag == .h2 {
            paragraphs.removeFirst(1)
        }
        paragraphs.forEach {
            buildParagraphForAttributedString(paragraph: headerTag.rawValue + $0, configureAttributesInString: headerTag.rawValue + $0, mutableAttributedString: &mutableAttributedString, headerTag: headerTag)
        }
    }
    
    static func makeAttributedStringFromHTML(url: URL) -> NSMutableAttributedString? {
        guard let contents = try? String(contentsOf: url) else { return nil }
        var mutableAttributedString = NSMutableAttributedString()
        hasFormattedHThreeSubtitles = false
        
        let firstParagraph = contents.slice(from: HTMLHeaderTag.h1.rawValue, to: HTMLHeaderTag.h2.rawValue) ?? ""
        buildParagraphForAttributedString(paragraph: firstParagraph, configureAttributesInString: contents, mutableAttributedString: &mutableAttributedString, headerTag: .h1)
        
        if contents.contains(HTMLHeaderTag.h2.rawValue) {
            configureParagraphs(separatedByHeaderTags: .h2, in: contents, mutableAttributedString: &mutableAttributedString)
        }
        
        if contents.contains(HTMLHeaderTag.h3.rawValue) && !hasFormattedHThreeSubtitles {
            configureParagraphs(separatedByHeaderTags: .h3, in: contents, mutableAttributedString: &mutableAttributedString)
        }
        
        // If we have reached this point and the string is empty, we have no H2 or H3 tags. Format entire contents and possible H1s
        if mutableAttributedString.string.isEmpty {
            buildParagraphForAttributedString(paragraph: contents, configureAttributesInString: contents, mutableAttributedString: &mutableAttributedString, headerTag: .h1)
        }
        
        return mutableAttributedString
    }
}
