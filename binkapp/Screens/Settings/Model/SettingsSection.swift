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
    
    enum RowType: String {
        case preferences = "settings_row_preferences_title"
        case logout = "settings_row_logout_title"
        case faq = "settings_row_faqs_title"
        case contactUs = "settings_row_contact_title"
        case rateThisApp = "settings_row_rateapp_title"
        case securityAndPrivacy = "settings_row_security_title"
        case howItWorks = "settings_row_howitworks_title"
        case privacyPolicy = "settings_row_privacypolicy_title"
        case termsAndConditions = "settings_row_termsandconditions_title"
        case debug = "settings_section_debug_title"
        case whoWeAre = "settings_who_we_are_title"
        case theme = "settings_row_theme_title"
    }
    
    enum RowAction {
        case pushToViewController(viewController: UIViewController.Type)
        case pushToReusable(screen: ReusableScreen)
        case logout
        case customAction(action: VoidClosure)
        case launchSupport(service: SupportService)
    }
    
    enum ReusableScreen {
        case securityAndPrivacy
        case howItWorks
        case privacyPolicy
        case termsAndConditions
    }

    enum SupportService {
        case faq
        case contactUs
    }
    
    let type: RowType
    
    var title: String {
        return type.rawValue.localized
    }
    
    let subtitle: String?
    let action: RowAction
    let actionRequired: Bool
    
    init(type: RowType, subtitle: String? = nil, action: RowAction, actionRequired: Bool) {
        self.type = type
        self.subtitle = subtitle
        self.action = action
        self.actionRequired = actionRequired
    }
}
