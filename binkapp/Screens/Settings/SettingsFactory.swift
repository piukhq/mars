//
//  SettingsFactory.swift
//  binkapp
//
//  Created by Max Woodhams on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct SettingsFactory {
    private let router: MainScreenRouter
    
    init(router: MainScreenRouter) {
        self.router = router
    }
    
    func sectionData() -> [SettingsSection] {
        
        var sections = [SettingsSection]()
        
        // MARK: - Account
        
        let accountSection = SettingsSection(title: "settings_section_account_title".localized, rows: [
            SettingsRow(
                title: "settings_row_preferences_title".localized,
                action: .pushToViewController(viewController: PreferencesViewController.self)
            ),
            SettingsRow(
                title: "settings_row_logout_title".localized,
                action: .logout
            )
        ])
        
        sections.append(accountSection)
        
        // MARK: - Support and feedback
        
        let supportSection = SettingsSection(title: "settings_section_support_title".localized, rows: [
            SettingsRow(
                title: "settings_row_faqs_title".localized,
                subtitle: "settings_row_faqs_subtitle".localized,
                action: .customAction(action: {
                    MainScreenRouter.openExternalURL(
                        with: "https://help.bink.com"
                    )
                })
            ),
            SettingsRow(
                title: "settings_row_contact_title".localized,
                subtitle: "settings_row_contact_subtitle".localized,
                action: .contactUsAction
            ),
            SettingsRow(
                title: "settings_row_rateapp_title".localized,
                action: .customAction(action: {
                    MainScreenRouter.openExternalURL(
                        with: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931?action=write-review"
                    )
                })
            )
        ])
        
        sections.append(supportSection)
        
        // MARK: - About
        
        let aboutSection = SettingsSection(title: "settings_section_about_title".localized, rows: [
            SettingsRow(
                title: "settings_row_security_title".localized,
                subtitle: "settings_row_security_subtitle".localized,
                action: .pushToReusable(screen: .securityAndPrivacy)
            ),
            SettingsRow(
                title: "settings_row_howitworks_title".localized,
                subtitle: "settings_row_howitworks_subtitle".localized,
                action: .pushToReusable(screen: .howItWorks)
            )
        ])
        
        sections.append(aboutSection)
        
        // MARK: - Legal
        
        let legalSection = SettingsSection(title: "settings_section_legal_title".localized, rows: [
            SettingsRow(
                title: "settings_row_privacypolicy_title".localized,
                action: .customAction(action: {
                    MainScreenRouter.openExternalURL(with: "https://bink.com/privacy-policy/")
                })
            ),
            SettingsRow(
                title: "settings_row_termsandconditions_title".localized,
                action: .customAction(action: {
                    MainScreenRouter.openExternalURL(with: "https://bink.com/terms-and-conditions/")
                })
            )
        ])
        
        sections.append(legalSection)
        
        // MARK: - Debug
        
        #if DEBUG
        let debugSection = SettingsSection(title: "settings_section_debug_title".localized, rows: [
            SettingsRow(
                title: "settings_section_debug_title".localized,
                subtitle: "settings_section_debug_subtitle".localized,
                action: .pushToViewController(viewController: DebugMenuTableViewController.self)
            )
        ])
        
        sections.append(debugSection)
        #endif
        
        return sections
    }
}
