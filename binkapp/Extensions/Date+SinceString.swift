//
//  Date+SinceString.swift
//  binkapp
//
//  Created by Paul Tiriteu on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoString() -> String? {
        let interval = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: Date())
        let days = interval.day ?? 0
        let hours = interval.hour ?? 0
        let minutes = interval.minute ?? 0
        
        if days > 0 {
            return "\(days) \(days > 1 ? "days".localized : "day".localized)"
        }
        
        if hours > 0 {
            return "\(hours) \(hours > 1 ? "hours".localized : "hour".localized)"
        }
        
        if minutes > 0 {
            return "\(minutes) \(minutes > 1 ? "minutes".localized : "minute".localized)"
        }
        
        return nil
    }

    func getFormattedString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
