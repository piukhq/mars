//
//  ThemeManager.swift
//  binkapp
//
//  Created by Nick Farrant on 19/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct ThemeManager {
    enum ScreenElement {
        case viewBackground
        case walletCardBackground
        case divider
        case text
    }

    var currentTheme: Theme {
        didSet {
            // TODO: Set user default value
        }
    }

    init(theme: Theme.ThemeType) {
        self.currentTheme = Theme(type: theme)
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
