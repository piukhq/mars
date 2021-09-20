//
//  UIColor+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

extension UIColor {
    public func isLight(threshold: CGFloat = 0.5) -> Bool {
        let originalCGColor = cgColor

        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return false
        }
        guard components.count >= 3 else {
            return false
        }
        let brightness = CGFloat(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1_000)
        return brightness > threshold
    }
}
