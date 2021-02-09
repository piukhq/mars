//
//  UIColor+binkapp.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(hexString.startIndex, offsetBy: 1)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
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
    static let binkBlueDivider = UIColor(hexString: "767676")
    static let binkBlueText = UIColor(hexString: "FFFFFF")
    static let binkBlueBarBackground = UIColor(hexString: "0E0E2A")
    static let binkBlueTableCellSelection = binkBlueViewBackground.darker(by: 3) ?? .binkBlueDivider
    
    // MARK: Bink custom dynamic colours
    static let binkDynamicGrayLight = UIColor(hexString: "d1d1d6")
    static let binkDynamicGrayDark = UIColor.darkGray.withAlphaComponent(0.3)

    static var binkDynamicGray: UIColor {
        switch Current.themeManager.currentTheme.type {
        case .system:
            return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                return traitcollection.userInterfaceStyle == .light ? .binkDynamicGrayLight : .binkBlueDivider
            }
        case .light:
            return binkDynamicGrayLight
        case .dark:
            return binkBlueDivider
        }
    }
    
    static var binkDynamicGray2: UIColor {
        switch Current.themeManager.currentTheme.type {
        case .system:
            return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                return traitcollection.userInterfaceStyle == .light ? .binkDynamicGrayLight : .binkDynamicGrayDark
            }
        case .light:
            return .binkDynamicGrayLight
        case .dark:
            return .binkDynamicGrayDark
        }
    }

    static var binkDynamicRed: UIColor {
        switch Current.themeManager.currentTheme.type {
        case .system:
            return .systemRed
        case .light:
            return UIColor(hexString: "ff3b30")
        case .dark:
            return UIColor(hexString: "ff453a")
        }
    }
}
