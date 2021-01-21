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
    let walletCardBackgroundColor: UIColor
    let dividerColor: UIColor
    let textColor: UIColor
    let barColor: UIColor
    let barBlurStyle: UIBlurEffect.Style
    let statusBarStyle: UIStatusBarStyle

    static let binkDarkBlue = CustomThemeConfiguration(viewBackgroundColor: .binkBlueViewBackground, walletCardBackgroundColor: .binkBlueCardBackground, dividerColor: .binkBlueDividerColor, textColor: .binkBlueTextColor, barColor: .binkBlueViewBackground, barBlurStyle: .dark, statusBarStyle: .lightContent)

    func toUserDefaultsData() -> [String: Any] {
        return [
            "viewBackgroundColor": viewBackgroundColor.toHex(alpha: true) ?? "",
            "walletCardBackgroundColor": walletCardBackgroundColor.toHex(alpha: true) ?? "",
            "dividerColor": dividerColor.toHex(alpha: true) ?? "",
            "textColor": textColor.toHex(alpha: true) ?? "",
            "barColor": barColor.toHex(alpha: true) ?? "",
            "barBlurStyle": barBlurStyle.rawValue,
            "statusBarStyle": statusBarStyle.rawValue
        ]
    }

    static func fromUserDefaultsData(_ data: [String: Any]) -> CustomThemeConfiguration? {
        guard let viewBackgroundColorHex = data["viewBackgroundColor"] as? String else { return nil }
        guard let walletCardBackgroundColorHex = data["walletCardBackgroundColor"] as? String else { return nil }
        guard let dividerColorHex = data["dividerColor"] as? String else { return nil }
        guard let textColorHex = data["textColor"] as? String else { return nil }
        guard let barColorHex = data["barColor"] as? String else { return nil }
        guard let barBlurStyleRawValue = data["barBlurStyle"] as? Int, let barBlurStyle = UIBlurEffect.Style(rawValue: barBlurStyleRawValue) else { return nil }
        guard let statusBarStyleRawValue = data["statusBarStyle"] as? Int, let statusBarStyle = UIStatusBarStyle(rawValue: statusBarStyleRawValue) else { return nil }

        return CustomThemeConfiguration(viewBackgroundColor: UIColor(hexString: viewBackgroundColorHex), walletCardBackgroundColor: UIColor(hexString: walletCardBackgroundColorHex), dividerColor: UIColor(hexString: dividerColorHex), textColor: UIColor(hexString: textColorHex), barColor: UIColor(hexString: barColorHex), barBlurStyle: barBlurStyle, statusBarStyle: statusBarStyle)
    }
}

struct Theme {
    enum ThemeType {
        case light
        case dark
        case system
        case custom(CustomThemeConfiguration)

        var userDefaultsId: Int {
            switch self {
            case .light:
                return 0
            case .dark:
                return 1
            case .system:
                return 2
            case .custom:
                return 3
            }
        }

        static func fromUserDefaults() -> ThemeType? {
            let themeTypeId = Current.userDefaults.value(forDefaultsKey: .theme) as? Int
            let customThemeConfigData = Current.userDefaults.value(forDefaultsKey: .customThemeConfig) as? [String: Any]

            switch themeTypeId {
            case 0:
                return .light
            case 1:
                return .dark
            case 2:
                return .system
            case 3:
                guard let data = customThemeConfigData else { return nil }
                guard let config = CustomThemeConfiguration.fromUserDefaultsData(data) else { return nil }
                return .custom(config)
            default: return nil
            }
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
}
