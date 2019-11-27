//
//  String+Localization.swift
//  binkapp
//
//  Created by Paul Tiriteu on 02/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        let string = NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        
        if string == self {
            fatalError("Missing localization for key \(self)!")
        }
        
        return string
    }
}
