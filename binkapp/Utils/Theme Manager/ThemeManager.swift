//
//  ThemeManager.swift
//  binkapp
//
//  Created by Nick Farrant on 19/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct CustomThemeConfiguration {
    let viewBackgroundColor: UIColor
    let walletCardBackground: UIColor
    let dividerColor: UIColor
    let textColor: UIColor
}

struct Theme {
    enum ThemeType {
        case light
        case dark
        case system
        case custom(CustomThemeConfiguration)
    }

    let type: ThemeType

    var viewControllerBackgroundColor: UIColor {
        return Styling.Colors.viewBackground
    }

    var walletCardBackgroundColor: UIColor {
        return Styling.Colors.walletCardBackground
    }

    var dividerColor: UIColor {
        return Styling.Colors.dividerColor
    }

    var textColor: UIColor {
        return Styling.Colors.textColor
    }
}

struct ThemeManager {
    enum ScreenElement {
        case viewBackground
        case walletCardBackground
        case divider
        case text
    }

    var currentTheme = Theme(type: .system) {
        didSet {
            // TODO: Set user default value
        }
    }

    mutating func setTheme(_ newTheme: Theme) {
        currentTheme = newTheme
    }

    func color(for element: ScreenElement) -> UIColor {
        switch element {
        case .viewBackground:
            return currentTheme.viewControllerBackgroundColor
        case .walletCardBackground:
            return currentTheme.walletCardBackgroundColor
        case .divider:
            return currentTheme.dividerColor
        case .text:
            return currentTheme.textColor
        }
    }
}

struct Styling {
    struct Colors {
        static var viewBackground: UIColor = {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return binkBlueViewBackground
            case .custom(let config):
                return config.viewBackgroundColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : binkBlueViewBackground
                }
            }
        }()

        static var walletCardBackground: UIColor = {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return binkBlueCardBackground
            case .custom(let config):
                return config.walletCardBackground
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : binkBlueCardBackground
                }
            }
        }()

        static var dividerColor: UIColor = {
            switch Current.themeManager.currentTheme.type {
            case .light:
                // TODO: Check current divider colours
                return .black
            case .dark:
                return .white
            case .custom(let config):
                return config.dividerColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : binkBlueDividerColor
                }
            }
        }()

        static var textColor: UIColor = {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return binkBlueViewBackground
            case .custom(let config):
                return config.textColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : binkBlueTextColor
                }
            }
        }()

        // MARK: Custom theme colours

        static var binkBlue = CustomThemeConfiguration(viewBackgroundColor: binkBlueViewBackground, walletCardBackground: binkBlueCardBackground, dividerColor: dividerColor, textColor: textColor)

        private static var binkBlueViewBackground: UIColor = {
            return UIColor(hexString: "111127")
        }()

        private static var binkBlueCardBackground: UIColor = {
            return UIColor(hexString: "1A1A38")
        }()

        private static var binkBlueDividerColor: UIColor = {
            return UIColor(hexString: "767676")
        }()

        private static var binkBlueTextColor: UIColor = {
            return UIColor(hexString: "FFFFFF")
        }()
    }
}
