//
//  ThemeManager.swift
//  binkapp
//
//  Created by Nick Farrant on 19/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class ThemeManager {
    enum ScreenElement {
        case viewBackground
        case walletCardBackground
        case divider
        case text
        case tabBar
    }

    var currentTheme: Theme {
        didSet {
            Current.userDefaults.set(currentTheme.type.userDefaultsId, forDefaultsKey: .theme)

            if case .custom(let config) = Current.themeManager.currentTheme.type {
                Current.userDefaults.set(config.toUserDefaultsData(), forDefaultsKey: .customThemeConfig)
            } else {
                Current.userDefaults.set(nil, forDefaultsKey: .customThemeConfig)
            }

            NotificationCenter.default.post(name: .themeManagerDidSetTheme, object: nil)
        }
    }

    init() {
        if let preferredThemeType = Theme.ThemeType.fromUserDefaults() {
            self.currentTheme = Theme(type: preferredThemeType)
        } else {
            self.currentTheme = Theme(type: .system)
        }
    }

    init(theme: Theme.ThemeType) {
        self.currentTheme = Theme(type: theme)
    }

    func setTheme(_ newTheme: Theme) {
        currentTheme = newTheme
    }

    func color(for element: ScreenElement) -> UIColor {
        switch element {
        case .viewBackground:
            return currentTheme.viewBackgroundColor
        case .walletCardBackground:
            return currentTheme.walletCardBackgroundColor
        case .divider:
            return currentTheme.dividerColor
        case .text:
            return currentTheme.textColor
        case .tabBar:
            return currentTheme.barColor
        }
    }

    func tabBarAppearance(for traitCollection: UITraitCollection) -> UITabBarAppearance {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.shadowImage = UIImage()
        tabAppearance.backgroundColor = Styling.Colors.bar
        tabAppearance.backgroundEffect = Styling.barBlur(for: traitCollection)
        return tabAppearance
    }

    func navBarAppearance(for traitCollection: UITraitCollection) -> UINavigationBarAppearance {
        let backInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        let backButtonImage = UIImage(named: "navbarIconsBack")?.withAlignmentRectInsets(backInsets)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = Styling.Colors.bar
        appearance.backgroundEffect = Styling.barBlur(for: traitCollection)
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navBar, NSAttributedString.Key.foregroundColor: Styling.Colors.text]
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        return appearance
    }
    
    func statusBarStyle(for traitCollection: UITraitCollection) -> UIStatusBarStyle {
        return Styling.statusBarStyle(for: traitCollection)
    }

    func addObserver(_ observer: Any, handler: Selector) {
        NotificationCenter.default.addObserver(observer, selector: handler, name: .themeManagerDidSetTheme, object: nil)
    }
}
