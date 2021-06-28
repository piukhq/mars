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
        var sections: [SettingsSection] = []
        
        // MARK: - Debug
        
        #if DEBUG
        let debugSection = SettingsSection(title: L10n.settingsSectionDebugTitle, rows: [
            SettingsRow(
                type: .debug,
                subtitle: L10n.settingsSectionDebugSubtitle,
                action: .pushToViewController(viewController: DebugMenuTableViewController.self),
                actionRequired: rowsWithActionRequired?.contains(.debug) ?? false
            )
        ])
        
        sections.append(debugSection)
        #endif
        
        // MARK: - Account
        
        let accountSection = SettingsSection(title: L10n.settingsSectionAccountTitle, rows: [
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
        
        // MARK: - Appearance
        
        let themeSettingsRow = SettingsRow(
            type: .theme,
            subtitle: nil,
            action: .customAction(action: {
                let ac = BinkAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let systemAction = UIAlertAction(title: L10n.settingsThemeSystemTitle, style: .default, handler: { _ in
                    Current.themeManager.setTheme(Theme(type: .system))
                })
                if let _ = systemAction.value(forKey: "checked") as? Bool {
                    systemAction.setValue(Current.themeManager.currentTheme.type == .system, forKey: "checked")
                }
                
                let lightAction = UIAlertAction(title: L10n.settingsThemeLightTitle, style: .default, handler: { _ in
                    Current.themeManager.setTheme(Theme(type: .light))
                })
                if let _ = lightAction.value(forKey: "checked") as? Bool {
                    lightAction.setValue(Current.themeManager.currentTheme.type == .light, forKey: "checked")
                }
                
                let darkAction = UIAlertAction(title: L10n.settingsThemeDarkTitle, style: .default, handler: { _ in
                    Current.themeManager.setTheme(Theme(type: .dark))
                })
                if let _ = darkAction.value(forKey: "checked") as? Bool {
                    darkAction.setValue(Current.themeManager.currentTheme.type == .dark, forKey: "checked")
                }
                
                ac.addAction(systemAction)
                ac.addAction(lightAction)
                ac.addAction(darkAction)
                ac.addAction(UIAlertAction(title: L10n.settingsThemeCancelTitle, style: .cancel))
                
                let navigationRequest = AlertNavigationRequest(alertController: ac)
                Current.navigate.to(navigationRequest)
            }),
            actionRequired: rowsWithActionRequired?.contains(.theme) ?? false
        )
        
        var appearanceSection = SettingsSection(title: L10n.settingsSectionAppearanceTitle, rows: [])
        
        if Current.featureManager.isFeatureEnabled(.themes) {
            appearanceSection.rows.append(themeSettingsRow)
        }
        
        if !appearanceSection.rows.isEmpty {
            sections.append(appearanceSection)
        }
        
        // MARK: - Support and feedback
        
        let supportSection = SettingsSection(title: L10n.settingsSectionSupportTitle, rows: [
            SettingsRow(
                type: .faq,
                subtitle: L10n.settingsRowFaqsSubtitle,
                action: .launchSupport(service: .faq),
                actionRequired: rowsWithActionRequired?.contains(.faq) ?? false
            ),
            SettingsRow(
                type: .contactUs,
                subtitle: L10n.settingsRowContactSubtitle,
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
        
        let aboutSection = SettingsSection(title: L10n.settingsSectionAboutTitle, rows: [
            SettingsRow(
                type: .securityAndPrivacy,
                subtitle: L10n.settingsRowSecuritySubtitle,
                action: .pushToReusable(screen: .securityAndPrivacy),
                actionRequired: rowsWithActionRequired?.contains(.securityAndPrivacy) ?? false
            ),
            SettingsRow(
                type: .howItWorks,
                subtitle: L10n.settingsRowHowitworksSubtitle,
                action: .pushToReusable(screen: .howItWorks),
                actionRequired: rowsWithActionRequired?.contains(.howItWorks) ?? false
            ),
            SettingsRow(
                type: .whoWeAre,
                action: .pushToSwiftUIView(swiftUIView: .whoWeAre),
                actionRequired: rowsWithActionRequired?.contains(.whoWeAre) ?? false
            )
        ])
        
        sections.append(aboutSection)
        
        // MARK: - Legal
        
        let legalSection = SettingsSection(title: L10n.settingsSectionLegalTitle, rows: [
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
        
        // MARK: - Beta
        let action: SettingsRow.RowAction
        
        if #available(iOS 14.0, *) {
            action = .pushToSwiftUIView(swiftUIView: .featureFlags)
        } else {
            action = .pushToViewController(viewController: FeatureFlagsTableViewController.self)
        }
        
        let betaSection = SettingsSection(title: L10n.settingsSectionBetaTitle, rows: [
            SettingsRow(
                type: .featureFlags,
                action: action,
                actionRequired: rowsWithActionRequired?.contains(.featureFlags) ?? false)
        ])
        
        /// Only show beta section if user ID is contained in beta list group in remote config
        if Current.featureManager.shouldShowInSettings {
            sections.append(betaSection)
        }
        
        return sections
    }
}
