//
//  SettingsSection.swift
//  binkapp
//
//  Created by Max Woodhams on 11/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

struct SettingsSection: Identifiable {
    var id = UUID()
    let title: String
    var rows: [SettingsRow]
}

struct SettingsRow: Identifiable, Equatable {
    static func == (lhs: SettingsRow, rhs: SettingsRow) -> Bool {
        return lhs.id == rhs.id
    }
    
    typealias VoidClosure = () -> Void
    
    enum RowType: String {
        case preferences
        case logout
        case faq
        case contactUs
        case rateThisApp
        case securityAndPrivacy
        case howItWorks
        case privacyPolicy
        case termsAndConditions
        case debug
        case whoWeAre
        case theme
        case featureFlags
        case delete
        case previousUpdates
        
        var title: String {
            switch self {
            case .preferences:
                return L10n.settingsRowPreferencesTitle
            case .logout:
                return L10n.settingsRowLogoutTitle
            case .faq:
                return L10n.settingsRowFaqsTitle
            case .contactUs:
                return L10n.settingsRowContactTitle
            case .rateThisApp:
                return L10n.settingsRowRateappTitle
            case .securityAndPrivacy:
                return L10n.settingsRowSecurityTitle
            case .howItWorks:
                return L10n.settingsRowHowitworksTitle
            case .privacyPolicy:
                return L10n.settingsRowPrivacypolicyTitle
            case .termsAndConditions:
                return L10n.settingsRowTermsandconditionsTitle
            case .debug:
                return L10n.settingsSectionDebugTitle
            case .whoWeAre:
                return L10n.settingsWhoWeAreTitle
            case .theme:
                return L10n.settingsRowThemeTitle
            case .featureFlags:
                return L10n.settingsRowFeatureflagsTitle
            case .delete:
                return L10n.settingsRowDeleteAccountTitle
            case .previousUpdates:
                return "Previous Updates"
            }
        }
    }
    
    enum RowAction {
        case navigate(to: DestinationView)
        case logout
        case customAction(action: VoidClosure)
        case launchSupport(service: SupportService)
        case delete
    }

    enum SupportService {
        case faq
        case contactUs
    }
    
    enum DestinationView {
        case securityAndPrivacy
        case howItWorks
        case privacyPolicy
        case termsAndConditions
        case whoWeAre
        case featureFlags
        case debug
        case preferences
        case previousUpdates
    }
    
    let type: RowType
    
    var title: String {
        return type.title
    }
    
    let id = UUID()
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
