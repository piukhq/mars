//
//  BinkTextField.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkTextField: UITextField {
    override func layoutSubviews() {
        super.layoutSubviews()
        borderStyle = .none

        layer.cornerRadius = bounds.height / 2
        layer.backgroundColor = Current.themeManager.color(for: .walletCardBackground).cgColor

        if #available(iOS 14, *) {
            layer.borderWidth = 1.0
            layer.borderColor = Current.themeManager.color(for: .walletCardBackground).cgColor
            layer.masksToBounds = false
            layer.applyDefaultBinkShadow()
        } else {
            clipsToBounds = true
        }
                
        textColor = Current.themeManager.color(for: .text)
        tintColor = Current.themeManager.color(for: .text)
        
        switch Current.themeManager.currentTheme.type {
        case .light:
            overrideUserInterfaceStyle = .light
        case .dark:
            overrideUserInterfaceStyle = .dark
        case .system:
            overrideUserInterfaceStyle = .unspecified
        }
    }
}
