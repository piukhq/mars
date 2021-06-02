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
        case h1
        case h2
        case h3
        
        var openingTag: String {
            switch self {
            case .h1:
                return "<h1>"
            case .h2:
                return "<h2>"
            case .h3:
                return "<h3>"
            }
        }
        
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
        
        var headerString = htmlString.slice(from: headerTag.openingTag, to: headerTag.closingTag)
        headerString = headerString?.replacingOccurrences(of: "    ", with: " ")
        headerString = headerString?.replacingOccurrences(of: "&amp;", with: "&")
        headerString = headerString?.replacingOccurrences(of: "  ", with: " ")
        
        if let titleRange = attributedString.string.range(of: headerString ?? "") {
            let nsTitleRange = NSRange(titleRange, in: attributedString.string)
            attributedString.addAttribute(.font, value: headerTag.font, range: nsTitleRange)
        }
        
        configureLinks(in: htmlString, for: attributedString)
    }
    
    private static func buildParagraphForAttributedString(paragraph: String, stringFromHTML: String, mutableAttributedString: inout NSMutableAttributedString, headerTag: HTMLHeaderTag) {
        let newLine = NSAttributedString(string: "\n")

        if let htmlData = NSString(string: paragraph).data(using: String.Encoding.unicode.rawValue) {
            if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                if !attributedString.string.isEmpty {
                    configureAttributes(in: stringFromHTML, attributedString: attributedString, headerTag: headerTag)
                    
                    // If configuring H2 paragraphs, configure H3s
                    if headerTag == .h2 {
                        let paragraphsHThree = paragraph.components(separatedBy: HTMLHeaderTag.h3.openingTag)
                        paragraphsHThree.forEach {
                            configureAttributes(in: HTMLHeaderTag.h3.openingTag + $0, attributedString: attributedString, headerTag: .h3, shouldConfigureBodyText: false)
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
    
    static func makeAttributedStringFromHTML(url: URL) -> NSMutableAttributedString? {
        guard let contents = try? String(contentsOf: url) else { return nil }
        var mutableAttributedString = NSMutableAttributedString()
        hasFormattedHThreeSubtitles = false
        
        // First Paragraph
        let firstParagraph = contents.slice(from: HTMLHeaderTag.h1.openingTag, to: HTMLHeaderTag.h2.openingTag) ?? ""
        buildParagraphForAttributedString(paragraph: firstParagraph, stringFromHTML: contents, mutableAttributedString: &mutableAttributedString, headerTag: .h1)
        
        
        // Split paragraphs by H2 tags
        if contents.contains(HTMLHeaderTag.h2.openingTag) {
            let paragraphs = contents.components(separatedBy: HTMLHeaderTag.h2.openingTag)
            for paragraph in paragraphs.dropFirst() {
                let formattedParagraph = HTMLHeaderTag.h2.openingTag + paragraph
                buildParagraphForAttributedString(paragraph: formattedParagraph, stringFromHTML: formattedParagraph, mutableAttributedString: &mutableAttributedString, headerTag: .h2)
            }
        }
        
        // Split paragraphs by H3 tags
        if contents.contains(HTMLHeaderTag.h3.openingTag) && !hasFormattedHThreeSubtitles {
            let paragraphs = contents.components(separatedBy: HTMLHeaderTag.h3.openingTag)
            for paragraph in paragraphs {
                let formattedParagraph = HTMLHeaderTag.h3.openingTag + paragraph
                buildParagraphForAttributedString(paragraph: formattedParagraph, stringFromHTML: formattedParagraph, mutableAttributedString: &mutableAttributedString, headerTag: .h3)
            }
        }
        
        // If we have reached this point and the string is empty, we have no H2 or H3 tags.
        // Format entire contents and possible H1s
        if mutableAttributedString.string.isEmpty {
            buildParagraphForAttributedString(paragraph: contents, stringFromHTML: contents, mutableAttributedString: &mutableAttributedString, headerTag: .h1)
        }
        
        return mutableAttributedString
    }
    
    private static func configureLinks(in paragraph: String, for attributedString: NSMutableAttributedString) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
        let matches = detector.matches(in: paragraph, options: [], range: NSRange(location: 0, length: paragraph.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: paragraph) else { continue }
            var urlString = paragraph[range]
            guard let urlRange = attributedString.string.range(of: urlString) else { return }
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
                attributedString.addAttribute(.link, value: URL, range: NSRange(urlRange, in: attributedString.string))
            }
        }
    }
}
