//
//  Theme.swift
//  binkapp
//
//  Created by Nick Farrant on 20/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct CustomThemeConfiguration {
    let viewBackgroundColor: UIColor
    let walletCardBackground: UIColor
    let dividerColor: UIColor
    let textColor: UIColor
    let tabBar: UIColor
    let barBlur: UIBlurEffect

    static let binkDarkBlue = CustomThemeConfiguration(viewBackgroundColor: .binkBlueViewBackground, walletCardBackground: .binkBlueCardBackground, dividerColor: .binkBlueDividerColor, textColor: .binkBlueTextColor, tabBar: .binkBlueViewBackground, barBlur: UIBlurEffect(style: .dark))
}

struct Theme {
    enum ThemeType {
        case light
        case dark
        case system
        case custom(CustomThemeConfiguration)
    }

    let type: ThemeType

    var viewBackgroundColor: UIColor {
        return Styling.Colors.viewBackground
    }

    var walletCardBackgroundColor: UIColor {
        return Styling.Colors.walletCardBackground
    }

    var dividerColor: UIColor {
        return Styling.Colors.divider
    }

    var textColor: UIColor {
        return Styling.Colors.text
    }

    var tabBarColor: UIColor {
        return Styling.Colors.tabBar
    }
}
