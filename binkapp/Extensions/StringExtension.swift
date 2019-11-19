//
//  StringExtension.swift
//  binkapp
//
//  Created by Max Woodhams on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension String {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in
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
}
