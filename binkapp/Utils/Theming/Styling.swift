//
//  Styles.swift
//  binkapp
//
//  Created by Nick Farrant on 20/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum Styling {
    enum Colors {
        static var viewBackground: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return .binkBlueViewBackground
            case .custom(let config):
                return config.viewBackgroundColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : .binkBlueViewBackground
                }
            }
        }

        static var walletCardBackground: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return .binkBlueCardBackground
            case .custom(let config):
                return config.walletCardBackground
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : .binkBlueCardBackground
                }
            }
        }

        static var dividerColor: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                // TODO: Check current divider colours
                return .black
            case .dark:
                return .binkBlueDividerColor
            case .custom(let config):
                return config.dividerColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : .binkBlueDividerColor
                }
            }
        }

        static var textColor: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return .binkBlueTextColor
            case .custom(let config):
                return config.textColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : .binkBlueTextColor
                }
            }
        }
    }
}
