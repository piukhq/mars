//
//  Theme.swift
//  binkapp
//
//  Created by Nick Farrant on 20/01/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct Theme {
    enum ThemeType: Int {
        case light
        case dark
        case system

        static func fromUserDefaults() -> ThemeType? {
            guard let themeTypeId = Current.userDefaults.value(forDefaultsKey: .theme) as? Int else { return nil }
            return ThemeType(rawValue: themeTypeId)
        }
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

    var barColor: UIColor {
        return Styling.Colors.bar
    }
    
    var insetGroupedTableBackgroundColor: UIColor {
        return Styling.Colors.insetGroupedTable
    }
}
