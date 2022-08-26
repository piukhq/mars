//
//  DateManager.swift
//  binkapp
//
//  Created by Sean Williams on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

class DateManager: ObservableObject {
    enum Constants {
        static let oneDay: Double = 86400
    }
    
    @Published var currentDate = Date.now {
        didSet {
            let day = Calendar.current.dateComponents([.weekday], from: currentDate).weekday
            let fullFormatedDate = dayOfTheWeek(id: day) + " " + currentDate.formatted()
            MessageView.show(fullFormatedDate, type: .snackbar(.long))
        }
    }
    
    var currentHour: Int {
        return Calendar.current.component(.hour, from: currentDate)
    }
    
    func adjustDate(_ newDate: Date) {
        currentDate = newDate
    }
    
    func reset() {
        currentDate = Date.now
    }
    
    func today() -> Int {
        return Calendar.current.dateComponents([.weekday], from: currentDate).weekday ?? 0
    }
    
    func tomorrow() -> Int {
        return Calendar.current.dateComponents([.weekday], from: currentDate + Constants.oneDay).weekday ?? 0
    }
    
    func dayOfTheWeek(id: Int?) -> String {
        switch id {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return ""
        }
    }
}
