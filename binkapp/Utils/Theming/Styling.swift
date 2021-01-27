//
//  Styles.swift
//  binkapp
//
//  Created by Nick Farrant on 20/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum Styling {
    static func barBlur(for traitCollection: UITraitCollection) -> UIBlurEffect {
        switch Current.themeManager.currentTheme.type {
        case .light:
            return UIBlurEffect(style: .light)
        case .dark:
            return UIBlurEffect(style: .dark)
        case .system:
            return traitCollection.userInterfaceStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        }
    }
    
    static func statusBarStyle(for traitCollection: UITraitCollection) -> UIStatusBarStyle {
        switch Current.themeManager.currentTheme.type {
        case .light:
            return .darkContent
        case .dark:
            return .lightContent
        case .system:
            return .default
        }
    }
    
    static func scrollViewIndicatorStyle(for traitCollection: UITraitCollection) -> UIScrollView.IndicatorStyle {
        switch Current.themeManager.currentTheme.type {
        case .dark:
            return .white
        case .light:
            return .black
        case .system:
            return .default
        }
    }

    enum Colors {
        static var viewBackground: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .white
            case .dark:
                return .binkBlueViewBackground
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
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .white : .binkBlueCardBackground
                }
            }
        }

        static var divider: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                // TODO: Check current divider colours
                return .black
            case .dark:
                return .binkBlueDividerColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .black : .binkBlueDividerColor
                }
            }
        }

        static var text: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return .black
            case .dark:
                return .binkBlueTextColor
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? .black : .binkBlueTextColor
                }
            }
        }

        static var bar: UIColor {
            switch Current.themeManager.currentTheme.type {
            case .light:
                return UIColor.white.withAlphaComponent(0.6)
            case .dark:
                return UIColor.binkBlueViewBackground.withAlphaComponent(0.6)
            case .system:
                return UIColor { (traitcollection: UITraitCollection) -> UIColor in
                    return traitcollection.userInterfaceStyle == .light ? UIColor.white.withAlphaComponent(0.6) : UIColor.binkBlueViewBackground.withAlphaComponent(0.6)
                }
            }
        }
    }
}
