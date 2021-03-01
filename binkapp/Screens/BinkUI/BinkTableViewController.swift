//
//  BinkTableViewController.swift
//  binkapp
//
//  Created by Sean Williams on 25/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class BinkTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForCurrentTheme()
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureForCurrentTheme()
    }
    
    @objc func configureForCurrentTheme() {
        view.backgroundColor = Current.themeManager.color(for: .viewBackground)
        tableView.reloadData()
        switch Current.themeManager.currentTheme.type {
        case .light:
            view.window?.overrideUserInterfaceStyle = .light
        case .dark:
            view.window?.overrideUserInterfaceStyle = .dark
        case .system:
            view.window?.overrideUserInterfaceStyle = .unspecified
        }
    }
}
