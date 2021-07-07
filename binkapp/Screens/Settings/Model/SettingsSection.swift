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
    var rows: [SettingsRow]
}

struct SettingsRow {
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
            }
        }
    }
    
    enum RowAction {
        case pushToViewController(viewController: UIViewController.Type)
        case pushToSwiftUIView(swiftUIView: SwiftUIView)
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
    
    enum SwiftUIView {
        case whoWeAre
    }
    
    let type: RowType
    
    var title: String {
        return type.title
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
