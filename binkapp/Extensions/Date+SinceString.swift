//
//  TimeConverter.swift
//  binkapp
//
//  Created by Paul Tiriteu on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension Date {
    func timeAgoString() -> String? {
        let toDate = Date()
        
        if let interval = Calendar.current.dateComponents([.day], from: self, to: toDate).day, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "day".localized : "\(interval)" + " " + "days".localized
        }
        
        if let interval = Calendar.current.dateComponents([.hour], from: self, to: toDate).hour, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour".localized : "\(interval)" + " " + "hours".localized
        }
        
        if let interval = Calendar.current.dateComponents([.minute], from: self, to: toDate).minute, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute".localized : "\(interval)" + " " + "minutes".localized
        }
        
        return nil
    }
}
