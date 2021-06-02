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
    
    private static func fixIncorrectHTMLOccurences(in string: inout String?) {
        string = string?.replacingOccurrences(of: "    ", with: " ")
        string = string?.replacingOccurrences(of: "&amp;", with: "&")
        string = string?.replacingOccurrences(of: "  ", with: " ")
    }
    
    private static func addFontAttributeToHeader(in htmlString: String, attributedString: NSMutableAttributedString, headerTag: HTMLHeaderTag, shouldConfigureBodyText: Bool = true) {
        if shouldConfigureBodyText {
            attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
        }
        
        var headerString = htmlString.slice(from: headerTag.openingTag, to: headerTag.closingTag)
        fixIncorrectHTMLOccurences(in: &headerString)
        
        if let titleRange = attributedString.string.range(of: headerString ?? "") {
            let nsTitleRange = NSRange(titleRange, in: attributedString.string)
            attributedString.addAttribute(.font, value: headerTag.font, range: nsTitleRange)
        }
        
        configureLinks(in: htmlString, for: attributedString)
    }
    
    static func makeAttributedStringFromHTML(url: URL) -> NSMutableAttributedString? {
        if let contents = try? String(contentsOf: url) {
            var mutableAttributedString = NSMutableAttributedString()
            let newLine = NSAttributedString(string: "\n")
            
            // First Paragraph
            let firstParagraph = contents.slice(from: HTMLHeaderTag.h1.openingTag, to: HTMLHeaderTag.h2.openingTag) ?? ""
            if let htmlData = NSString(string: firstParagraph).data(using: String.Encoding.unicode.rawValue) {
                if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    if !attributedString.string.isEmpty {
                        addFontAttributeToHeader(in: contents, attributedString: attributedString, headerTag: .h1)
                        mutableAttributedString = attributedString
                        mutableAttributedString.append(newLine)
                    }
                }
            }
            
            // Remaining paragraphs
            var hasFormattedHThreeSubtitles = false
            
            // Split paragraphs by H2 tags
            if contents.contains(HTMLHeaderTag.h2.openingTag) {
                let paragraphs = contents.components(separatedBy: HTMLHeaderTag.h2.openingTag)
                for paragraph in paragraphs.dropFirst() {
                    let formattedParagraph = HTMLHeaderTag.h2.openingTag + paragraph
                    if let htmlData = NSString(string: formattedParagraph).data(using: String.Encoding.unicode.rawValue) {
                        if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                            addFontAttributeToHeader(in: formattedParagraph, attributedString: attributedString, headerTag: .h2)
                            
                            let paragraphsHThree = contents.components(separatedBy: HTMLHeaderTag.h3.openingTag)
                            paragraphsHThree.forEach {
                                addFontAttributeToHeader(in: HTMLHeaderTag.h3.openingTag + $0, attributedString: attributedString, headerTag: .h3, shouldConfigureBodyText: false)
                                hasFormattedHThreeSubtitles = true
                            }
                            
                            mutableAttributedString.append(attributedString)
                            mutableAttributedString.append(newLine)
                        }
                    }
                }
            }
            
            // Split paragraphs by H3 tags
            if contents.contains(HTMLHeaderTag.h3.openingTag) && !hasFormattedHThreeSubtitles {
                let paragraphs = contents.components(separatedBy: HTMLHeaderTag.h3.openingTag)
                for paragraph in paragraphs {
                    let formattedParagraph = HTMLHeaderTag.h3.openingTag + paragraph
                    if let htmlData = NSString(string: formattedParagraph).data(using: String.Encoding.unicode.rawValue) {
                        if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                            addFontAttributeToHeader(in: formattedParagraph, attributedString: attributedString, headerTag: .h3)
                            mutableAttributedString.append(attributedString)
                            mutableAttributedString.append(newLine)
                        }
                    }
                }
            }
            
            // If we have reached this point and the string is empty, we have no H2 or H3 tags.
            // Format entire contents and possible H1s
            if mutableAttributedString.string.isEmpty {
                if let htmlData = NSString(string: contents).data(using: String.Encoding.unicode.rawValue) {
                    if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                        if !attributedString.string.isEmpty {
                            addFontAttributeToHeader(in: contents, attributedString: attributedString, headerTag: .h1)
                            mutableAttributedString = attributedString
                        }
                    }
                }
            }
            
            return mutableAttributedString
        }
        return nil
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
