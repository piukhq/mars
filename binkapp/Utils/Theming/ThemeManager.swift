//
//  ThemeManager.swift
//  binkapp
//
//  Created by Nick Farrant on 19/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class ThemeManager: ObservableObject {
    enum ScreenElement {
        case viewBackground
        case walletCardBackground
        case divider
        case text
        case bar
        case insetGroupedTableBackground
    }

    init() {
        currentTheme = Theme(type: .light) /// Need to initialise currentTheme property before accessing self
        applyPreferredTheme()
    }

    init(theme: Theme.ThemeType) {
        self.currentTheme = Theme(type: theme)
    }

    @Published var currentTheme: Theme {
        didSet {
            if Current.featureManager.isFeatureEnabled(.themes) {
                Current.userDefaults.set(currentTheme.type.rawValue, forDefaultsKey: .theme)
            }
            NotificationCenter.default.post(name: .themeManagerDidSetTheme, object: nil)
        }
    }
    
    func applyPreferredTheme() {
        if Current.featureManager.isFeatureEnabled(.themes) {
            if let preferredThemeType = Theme.ThemeType.fromUserDefaults() {
                self.currentTheme = Theme(type: preferredThemeType)
            } else {
                self.currentTheme = Theme(type: .system)
            }
        } else {
            self.currentTheme = Theme(type: .light)
        }
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
        case .bar:
            return currentTheme.barColor
        case .insetGroupedTableBackground:
            return currentTheme.insetGroupedTableBackgroundColor
        }
    }
    
    func overrideUserInterfaceStyle(for view: UIView) {
        switch Current.themeManager.currentTheme.type {
        case .light:
            view.overrideUserInterfaceStyle = .light
        case .dark:
            view.overrideUserInterfaceStyle = .dark
        case .system:
            view.overrideUserInterfaceStyle = .unspecified
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
        let backButtonImage = Asset.navbarIconsBack.image.withAlignmentRectInsets(backInsets)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = Styling.Colors.bar
        appearance.backgroundEffect = Styling.barBlur(for: traitCollection)
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navBar, NSAttributedString.Key.foregroundColor: Styling.Colors.text]
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        return appearance
    }
    
    func toolbarAppearance(for traitCollection: UITraitCollection) -> UIToolbarAppearance {
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowImage = UIImage()
        appearance.backgroundColor = Styling.Colors.bar
        appearance.backgroundEffect = Styling.barBlur(for: traitCollection)
        return appearance
    }
    
    func statusBarStyle(for traitCollection: UITraitCollection) -> UIStatusBarStyle {
        return Styling.statusBarStyle(for: traitCollection)
    }
    
    func scrollViewIndicatorStyle(for traitCollection: UITraitCollection) -> UIScrollView.IndicatorStyle {
        return Styling.scrollViewIndicatorStyle(for: traitCollection)
    }

    func addObserver(_ observer: Any, handler: Selector) {
        NotificationCenter.default.addObserver(observer, selector: handler, name: .themeManagerDidSetTheme, object: nil)
    }
}