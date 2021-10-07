//
//  DateExtension.swift
//  binkapp
//
//  Created by Paul Tiriteu on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum DateFormat: String {
    case dayMonthYear = "dd MMMM yyyy"
    case dayShortMonthYear = "dd MMM yyyy"
    case dayShortMonthYearWithSlash = "dd/MM/yyyy"
    case dayShortMonthYear24HourSecond = "dd MMM yyyy HH:mm:ss"
}

extension Date {
    func timeAgoString(short: Bool = false) -> String? {
        let interval = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: Date())
        let days = interval.day ?? 0
        let hours = interval.hour ?? 0
        let minutes = interval.minute ?? 0
        
        if days > 0 {
            if short {
                return "\(days)d"
            }
            
            switch days {
            case 1:
                return "\(days) \(L10n.day)"
            default: return "\(days) \(L10n.days)"
            }
        }
        
        if hours > 0 {
            if short {
                return "\(hours)h"
            }
            
            switch hours {
            case 1:
                return "\(hours) \(L10n.hour)"
            default: return "\(hours) \(L10n.hours)"
            }
        }
        
        if minutes >= 0 {
            if short {
                return "\(minutes)m"
            }
            
            switch minutes {
            case 1:
                return "\(minutes) \(L10n.minute)"
            default: return "\(minutes) \(L10n.minutes)"
            }
        }
        
        return nil
    }

    func getFormattedString(format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }

    static func makeDate(year: Int, month: Int, day: Int, hr: Int, min: Int, sec: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: year, month: month, day: day, hour: hr, minute: min, second: sec)
        return calendar.date(from: components)
    }
    
    func isBefore(date: Date, toGranularity: Calendar.Component) -> Bool {
        let comparisonResult = Calendar.current.compare(self, to: date, toGranularity: toGranularity)
        
        switch comparisonResult {
        case .orderedSame:
            return false
        case .orderedDescending:
            return false
        case .orderedAscending:
            return true
        }
    }

    var monthHasNotExpired: Bool {
        return !self.isBefore(date: Date(), toGranularity: .month)
    }

    static func numberOfSecondsIn(days: Int) -> Int {
        return days * 24 * 60 * 60
    }

    static func numberOfSecondsIn(hours: Int) -> Int {
        return hours * 60 * 60
    }

    static func numberOfSecondsIn(minutes: Int) -> Int {
        return minutes * 60
    }

    static func hasElapsed(days: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(days: days)
    }

    static func hasElapsed(hours: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(hours: hours)
    }

    static func hasElapsed(minutes: Int, since date: Date) -> Bool {
        let elapsed = Int(Date().timeIntervalSince(date))
        return elapsed >= Date.numberOfSecondsIn(minutes: minutes)
    }
}
