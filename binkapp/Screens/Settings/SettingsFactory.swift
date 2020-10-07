//
//  SettingsFactory.swift
//  binkapp
//
//  Created by Max Woodhams on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct SettingsFactory {
    private let rowsWithActionRequired: [SettingsRow.RowType]?
    
    init(rowsWithActionRequired: [SettingsRow.RowType]?) {
        self.rowsWithActionRequired = rowsWithActionRequired
    }
    
    func sectionData() -> [SettingsSection] {
        
        var sections = [SettingsSection]()
        
        // MARK: - Account
        
        let accountSection = SettingsSection(title: "settings_section_account_title".localized, rows: [
            SettingsRow(
                type: .preferences,
                action: .pushToViewController(viewController: PreferencesViewController.self),
                actionRequired: rowsWithActionRequired?.contains(.preferences) ?? false
            ),
            SettingsRow(
                type: .logout,
                action: .logout,
                actionRequired: rowsWithActionRequired?.contains(.logout) ?? false
            )
        ])
        
        sections.append(accountSection)
        
        // MARK: - Support and feedback
        
        let supportSection = SettingsSection(title: "settings_section_support_title".localized, rows: [
            SettingsRow(
                type: .faq,
                subtitle: "settings_row_faqs_subtitle".localized,
                action: .launchSupport(service: .faq),
                actionRequired: rowsWithActionRequired?.contains(.faq) ?? false
            ),
            SettingsRow(
                type: .contactUs,
                subtitle: "settings_row_contact_subtitle".localized,
                action: .launchSupport(service: .contactUs),
                actionRequired: rowsWithActionRequired?.contains(.contactUs) ?? false
            ),
            SettingsRow(
                type: .rateThisApp,
                action: .customAction(action: {
                    let navigationRequest = ExternalUrlNavigationRequest(urlString: "https://apps.apple.com/gb/app/bink-loyalty-rewards-wallet/id1142153931?action=write-review")
                    Current.navigate.to(navigationRequest)
                }),
                actionRequired: rowsWithActionRequired?.contains(.rateThisApp) ?? false
            )
        ])
        
        sections.append(supportSection)
        
        // MARK: - About
        
        let aboutSection = SettingsSection(title: "settings_section_about_title".localized, rows: [
            SettingsRow(
                type: .securityAndPrivacy,
                subtitle: "settings_row_security_subtitle".localized,
                action: .pushToReusable(screen: .securityAndPrivacy),
                actionRequired: rowsWithActionRequired?.contains(.securityAndPrivacy) ?? false
            ),
            SettingsRow(
                type: .howItWorks,
                subtitle: "settings_row_howitworks_subtitle".localized,
                action: .pushToReusable(screen: .howItWorks),
                actionRequired: rowsWithActionRequired?.contains(.howItWorks) ?? false
            ), SettingsRow(
                type: .whoWeAre,
                action: .pushToViewController(viewController: DebugMenuTableViewController.self),
                actionRequired: rowsWithActionRequired?.contains(.whoWeAre) ?? false
            )
        ])
        
        sections.append(aboutSection)
        
        // MARK: - Legal
        
        let legalSection = SettingsSection(title: "settings_section_legal_title".localized, rows: [
            SettingsRow(
                type: .privacyPolicy,
                action: .pushToReusable(screen: .privacyPolicy),
                actionRequired: rowsWithActionRequired?.contains(.privacyPolicy) ?? false
            ),
            SettingsRow(
                type: .termsAndConditions,
                action: .pushToReusable(screen: .termsAndConditions),
                actionRequired: rowsWithActionRequired?.contains(.termsAndConditions) ?? false
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
                actionRequired: rowsWithActionRequired?.contains(.debug) ?? false
            )
        ])
        
        sections.append(debugSection)
        #endif
        
        return sections
    }
}
