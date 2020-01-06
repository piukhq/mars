//
//  NSNumberExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 06/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

extension NSNumber {
    func twoDecimalPointString() -> String {
        guard floatValue.hasDecimals else {
            return "\(self).00"
        }
        return String(format: "%.02f", floatValue)
    }
}
