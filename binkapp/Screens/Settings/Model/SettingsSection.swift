//
//  SettingsSection.swift
//  binkapp
//
//  Created by Max Woodhams on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct SettingsSection {
    let title: String
    let rows: [SettingsRow]
}

struct SettingsRow {

    typealias VoidClosure = () -> Void
    
    enum RowAction {
        case pushToViewController(viewController: UIViewController.Type)
        case pushToReusable(screen: ReusableScreen)
        case customAction(action: VoidClosure)
        case contactUsAction
        case notImplemented //TODO: REMOVE ME BEFORE RELEASE!
    }
    
    enum ReusableScreen {
        case securityAndPrivacy
        case howItWorks
    }
    
    let title: String
    let subtitle: String?
    let action: RowAction
    
    init(title: String, subtitle: String? = nil, action: RowAction) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
}
