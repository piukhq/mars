//
//  UIColor+binkapp.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CFloat = 1.0) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            fatalError("Malformed hex string")
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            fatalError("Malformed hex string")
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 2 else {
            return nil
        }

        var r = Float(0.0)
        var g = Float(0.0)
        var b = Float(0.0)
        var a = Float(0.0)

        switch components.count {
        case 2:
            r = Float(components[0])
            g = Float(components[0])
            b = Float(components[0])
            a = Float(components[1])
        case 3:
            r = Float(components[0])
            g = Float(components[1])
            b = Float(components[2])
            a = Float(1.0)
        case 4:
            r = Float(components[0])
            g = Float(components[1])
            b = Float(components[2])
            a = Float(components[3])
        default: break
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    class var blueAccent: UIColor {
        return UIColor(red: 67 / 255, green: 113 / 255, blue: 254 / 255, alpha: 1)
    }
    
    class var binkPurple: UIColor {
        return UIColor(red: 180 / 255, green: 111 / 255, blue: 234 / 255, alpha: 1)
    }
    
    class var greenOk: UIColor {
        return UIColor(red: 0 / 255, green: 193 / 255, blue: 118 / 255, alpha: 1)
    }

    class var blueInactive: UIColor {
        return UIColor(red: 177 / 255, green: 194 / 255, blue: 203 / 255, alpha: 1)
    }

    static var facebookButton: UIColor {
        return UIColor(red: 59 / 255, green: 89 / 255, blue: 152 / 255, alpha: 1.0)
    }
    
    static var greyFifty: UIColor {
        return UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 1.0)
    }

    // MARK: - Card swipe gradients
    static let barcodeSwipeGradientLeft = UIColor(red: 180 / 255.0, green: 111 / 255.0, blue: 234 / 255.0, alpha: 1.0)
    static let barcodeSwipeGradientRight = UIColor(red: 67 / 255.0, green: 113 / 255.0, blue: 254 / 255.0, alpha: 1.0)

    static let deleteSwipeGradientLeft = UIColor(red: 1, green: 107 / 255.0, blue: 54 / 255.0, alpha: 1.0)
    static let deleteSwipeGradientRight = UIColor(red: 235 / 255.0, green: 0, blue: 27 / 255.0, alpha: 1.0)

    static let amberPending = UIColor(hexString: "#f5a623")
    static let redAttention = UIColor(hexString: "#eb001b")
    static let grey10 = UIColor(hexString: "#e5e5e5")
    static let disabledTextGrey = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    static let black15 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)


    // MARK: - Payment Card Gradient Colours

    static let visaGradientLeft = UIColor(hexString: "13288d")
    static let visaGradientRight = UIColor(hexString: "181c51")

    static let mastercardGradientLeft = UIColor(hexString: "f79e1b")
    static let mastercardGradientRight = UIColor(hexString: "eb001b")

    static let amexGradientLeft = UIColor(hexString: "57c4ff")
    static let amexGradientRight = UIColor(hexString: "006bcd")

    static let unknownGradientLeft = UIColor(hexString: "b46fea")
    static let unknownGradientRight = UIColor(hexString: "4371fe")

    static let visaPaymentCardGradients: [CGColor] = [UIColor.visaGradientLeft.cgColor, UIColor.visaGradientRight.cgColor]
    static let mastercardPaymentCardGradients: [CGColor] = [UIColor.mastercardGradientLeft.cgColor, UIColor.mastercardGradientRight.cgColor]
    static let amexPaymentCardGradients: [CGColor] = [UIColor.amexGradientLeft.cgColor, UIColor.amexGradientRight.cgColor]
    static let unknownPaymentCardGradients: [CGColor] = [UIColor.unknownGradientLeft.cgColor, UIColor.unknownGradientRight.cgColor]
    static let binkSwitchGradients: [CGColor] = [UIColor.binkPurple.cgColor, UIColor.blueAccent.cgColor]

    // MARK: - Loyalty card secondary color helpers

    /// Determine whether a UIColor is light
    ///
    /// - Parameter threshold: The threshold between light and dark. The higher this figure, the less likely a color is to be determined as light. Defaults to 0.5.
    /// - Returns: True or false for isLight
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

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: -1 * abs(percentage) )
    }

    private func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0), green: min(green + percentage / 100, 1.0), blue: min(blue + percentage / 100, 1.0), alpha: alpha)
        } else {
            return nil
        }
    }

    // MARK: - Theming

    // MARK: Bink Blue
    static let binkBlueViewBackground = UIColor(hexString: "111127")
    static let binkBlueCardBackground = UIColor(hexString: "1A1A38")
    static let binkBlueDividerColor = UIColor(hexString: "767676")
    static let binkBlueTextColor = UIColor(hexString: "FFFFFF")
}
