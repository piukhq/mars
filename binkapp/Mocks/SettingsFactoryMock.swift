//
//  SettingsFactoryMock.swift
//  binkapp
//
//  Created by Pop Dorin on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

// swiftlint:disable function_body_length
class SettingsFactoryMock {
    func sectionData() -> [SettingsSection] {
        var sections: [SettingsSection] = []
        
        // MARK: - Account
        
        let accountSection = SettingsSection(title: "settings_section_account_title".localized, rows: [
            SettingsRow(
                type: .preferences,
                action: .pushToViewController(viewController: PreferencesViewController.self),
                actionRequired: false
            ),
            SettingsRow(
                type: .logout,
                action: .logout,
                actionRequired: false
            )
        ])
        sections.append(accountSection)
        
        // MARK: - Support and feedback
        
        let supportSection = SettingsSection(title: "settings_section_support_title".localized, rows: [
            SettingsRow(
                type: .faq,
                subtitle: "settings_row_faqs_subtitle".localized,
                action: .launchSupport(service: .faq),
                actionRequired: false
            ),
            SettingsRow(
                type: .contactUs,
                subtitle: "settings_row_contact_subtitle".localized,
                action: .launchSupport(service: .contactUs),
                actionRequired: false
            ),
            SettingsRow(
                type: .rateThisApp,
                action: .customAction(action: {
                    let navigationRequest = ExternalUrlNavigationRequest(urlString: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931?action=write-review")
                    Current.navigate.to(navigationRequest)
                }),
                actionRequired: false
            )
        ])
        sections.append(supportSection)
        
        // MARK: - About
        
        let aboutSection = SettingsSection(title: "settings_section_about_title".localized, rows: [
            SettingsRow(
                type: .securityAndPrivacy,
                subtitle: "settings_row_security_subtitle".localized,
                action: .pushToReusable(screen: .securityAndPrivacy),
                actionRequired: false
            ),
            SettingsRow(
                type: .howItWorks,
                subtitle: "settings_row_howitworks_subtitle".localized,
                action: .pushToReusable(screen: .howItWorks),
                actionRequired: false
            )
        ])
        
        sections.append(aboutSection)
        
        // MARK: - Legal
        
        let legalSection = SettingsSection(title: "settings_section_legal_title".localized, rows: [
            SettingsRow(
                type: .privacyPolicy,
                action: .pushToReusable(screen: .privacyPolicy),
                actionRequired: false
            ),
            SettingsRow(
                type: .termsAndConditions,
                action: .pushToReusable(screen: .termsAndConditions),
                actionRequired: false
            )
        ])
        
        sections.append(legalSection)
        
        // MARK: - Debug
        
        #if DEBUG
        let debugSection = SettingsSection(title: "settings_section_debug_title".localized, rows: [
            SettingsRow(
                type: .debug,
                subtitle: "settings_section_debug_subtitle".localized,
                action: .pushToViewController(viewController: DebugMenuTableViewController.self),
                actionRequired: false
            )
        ])
        
        sections.append(debugSection)
        #endif
        
        return sections
    }
}
