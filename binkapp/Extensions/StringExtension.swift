//
//  StringExtension.swift
//  binkapp
//
//  Created by Max Woodhams on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

// swiftlint:disable force_unwrapping

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in
            return letters.randomElement()!
        })
    }
    
    static func fromTimestamp(_ timestamp: Double?, withFormat format: DateFormat, prefix: String? = nil, suffix: String? = nil) -> String? {
        guard let timestamp = timestamp else { return nil }
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return "\(prefix ?? "")\(formatter.string(from: date))\(suffix ?? "")"
    }
    
    func toNSString() -> NSString {
        return self as NSString
    }
    
    /// Convert a valid JSON string to a decoded Swift object.
    /// - Parameter objectType: The object type you are attempted to decode the JSON to. Passed in as String.self or [String].self.
    /// - Returns: An optional, fully typed decoded Swift object
    func asDecodedObject<T: Decodable>(ofType objectType: T.Type) -> T? {
        guard let data = data(using: .utf8) else { return nil }
        guard let decodedObject = try? JSONDecoder().decode(objectType, from: data) else { return nil }
        return decodedObject
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func ranges(of subString: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var range = NSRange(location: 0, length: count)
        while range.location != NSNotFound {
            range = (self as NSString).range(of: subString, options: .caseInsensitive, range: range)
            if range.location != NSNotFound {
                ranges.append(range)
                range = NSRange(location: range.location + range.length, length: count - (range.location + range.length))
            }
        }
        return ranges
    }
}
