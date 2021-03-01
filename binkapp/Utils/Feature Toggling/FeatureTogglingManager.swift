//
//  FeatureTogglingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct BetaUser: Codable {
    let uid: String
}

final class FeatureTogglingManager {
    var features: [Feature]? = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)

    var shouldShowInSettings: Bool {
        return userIsBetaUser
    }
    
    func getFeaturesFromRemoteConfig() {
        features = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)
        setupFeatures()
    }

    private var userIsBetaUser: Bool {
        let UID = Current.userManager.currentUserId ?? ""
        let betaUsers = Current.remoteConfig.objectForConfigKey(.betaUsers, forObjectType: [BetaUser].self)
        return betaUsers?.contains(where: { $0.uid == UID }) ?? false
    }

    func isFeatureEnabled(_ featureType: FeatureType) -> Bool {
        let feature = features?.first(where: { $0.type == featureType })
        return feature?.isEnabled ?? false
    }

    
    func toggle(_ feature: Feature, enabled: Bool) {
        switch feature.type {
        case .themes:
            let theme = Theme(type: enabled ? .system : .light)
            Current.themeManager.setTheme(theme)
            Current.userDefaults.set(theme.type.rawValue, forDefaultsKey: .theme)
        default:
            break
        }
        
        feature.storeToUserDefaults(enabled)
    }
    
    func setupFeatures() {
        features?.forEach { feature in
            switch feature.type {
            case .themes:
                Current.themeManager.applyPreferredTheme()
            default:
                break
            }
        }
    }
}
