//
//  HTMLParsingUtil.swift
//  binkapp
//
//  Created by Sean Williams on 01/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum HTMLParsingUtil {
    static func makeAttributedStringFromHTML(url: URL) -> NSMutableAttributedString? {
        if let contents = try? String(contentsOf: url) {
            var mutableAttributedString = NSMutableAttributedString()
            let newLine = NSAttributedString(string: "\n")
            
            // First Paragraph
            let firstParagraph = contents.slice(from: "<h1>", to: "<h2>") ?? ""
            if let htmlData = NSString(string: firstParagraph).data(using: String.Encoding.unicode.rawValue) {
                if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                    if !attributedString.string.isEmpty {
                        // Format all text
                        attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
                        
                        // Format title
                        let titleString = contents.slice(from: "<h1>", to: "</h1>")
                        var formattedTitle = titleString?.replacingOccurrences(of: "&amp;", with: "&")
                        formattedTitle = formattedTitle?.replacingOccurrences(of: "  ", with: " ")
                        if let titleRange = attributedString.string.range(of: formattedTitle ?? "") {
                            let nsTitleRange = NSRange(titleRange, in: attributedString.string)
                            attributedString.addAttribute(.font, value: UIFont.headline, range: nsTitleRange)
                        }
                        
                        configureLinks(in: firstParagraph, for: attributedString)
                        mutableAttributedString = attributedString
                        mutableAttributedString.append(newLine)
                    }
                }
            }
            
            // Remaining paragraphs
            var hasFormattedHThreeSubtitles = false
            
            // Split paragraphs by H2 tags
            if contents.contains("<h2>") {
                let paragraphs = contents.components(separatedBy: "<h2>")
                for paragraph in paragraphs.dropFirst() {
                    let formattedParagraph = "<h2>" + paragraph
                    if let htmlData = NSString(string: formattedParagraph).data(using: String.Encoding.unicode.rawValue) {
                        if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                            // Format all text
                            attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
                            
                            // Format H2 subtitle
                            var subtitle = formattedParagraph.slice(from: "<h2>", to: "</h2>")
                            subtitle = subtitle?.replacingOccurrences(of: "    ", with: " ")
                            subtitle = subtitle?.replacingOccurrences(of: "&amp;", with: "&")
                            
                            if let subtitleRange = attributedString.string.range(of: subtitle ?? "") {
                                let nsSubtitleRange = NSRange(subtitleRange, in: attributedString.string)
                                attributedString.addAttribute(.font, value: UIFont.subtitle, range: nsSubtitleRange)
                            }
                            
                            // Format H3 subtitle
                            let paragraphsHThree = contents.components(separatedBy: "<h3>")
                            paragraphsHThree.forEach {
                                let formattedParagraph = "<h3>" + $0
                                let subtitleHThree = formattedParagraph.slice(from: "<h3>", to: "</h3>")
                                if let subtitleRange = attributedString.string.range(of: subtitleHThree ?? "") {
                                    let nsSubtitleRange = NSRange(subtitleRange, in: attributedString.string)
                                    attributedString.addAttribute(.font, value: UIFont.linkTextButtonNormal, range: nsSubtitleRange)
                                }
                                hasFormattedHThreeSubtitles = true
                            }
                            
                            configureLinks(in: paragraph, for: attributedString)
                            
                            mutableAttributedString.append(attributedString)
                            mutableAttributedString.append(newLine)
                        }
                    }
                }
            }
            
            // Split paragraphs by H3 tags
            if contents.contains("<h3>") && !hasFormattedHThreeSubtitles {
                let paragraphs = contents.components(separatedBy: "<h3>")
                for paragraph in paragraphs {
                    let formattedParagraph = "<h3>" + paragraph
                    if let htmlData = NSString(string: formattedParagraph).data(using: String.Encoding.unicode.rawValue) {
                        if let attributedString = try? NSMutableAttributedString(data: htmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                            // Format all text
                            attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
                            
                            // Format subtitle
                            let subtitle = formattedParagraph.slice(from: "<h3>", to: "</h3>")
                            if let subtitleRange = attributedString.string.range(of: subtitle ?? "") {
                                let nsSubtitleRange = NSRange(subtitleRange, in: attributedString.string)
                                attributedString.addAttribute(.font, value: UIFont.subtitle, range: nsSubtitleRange)
                            }
                            
                            configureLinks(in: paragraph, for: attributedString)
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
                            // Format all text
                            attributedString.addAttribute(.font, value: UIFont.bodyTextLarge, range: NSRange(location: 0, length: attributedString.string.count - 1))
                            
                            // Format title
                            let titleString = contents.slice(from: "<h1>", to: "</h1>")
                            let formattedTitle = titleString?.replacingOccurrences(of: "&amp;", with: "&")
                            if let titleRange = attributedString.string.range(of: formattedTitle ?? "") {
                                let nsTitleRange = NSRange(titleRange, in: attributedString.string)
                                attributedString.addAttribute(.font, value: UIFont.headline, range: nsTitleRange)
                            }
                            
                            configureLinks(in: contents, for: attributedString)
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
