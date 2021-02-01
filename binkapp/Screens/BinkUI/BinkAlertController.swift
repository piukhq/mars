//
//  BinkAlertController.swift
//  binkapp
//
//  Created by Sean Williams on 01/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BinkAlertController: UIAlertController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }
    
    @objc func configureForCurrentTheme() {
        view.tintColor = Current.themeManager.color(for: .text)
        
        switch Current.themeManager.currentTheme.type {
        case .dark:
            overrideUserInterfaceStyle = .dark
        case .light:
            overrideUserInterfaceStyle = .light
        case .system:
            overrideUserInterfaceStyle = .unspecified
        }
    }
}
