//
//  DateManager.swift
//  binkapp
//
//  Created by Sean Williams on 23/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

class DateManager {
    var currentDate = Date.now {
        didSet {
            print(currentDate.formatted())
            MessageView.show(currentDate.formatted(), type: .snackbar(.long))
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
}
