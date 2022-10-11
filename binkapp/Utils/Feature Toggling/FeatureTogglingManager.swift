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

final class FeatureTogglingManager: ObservableObject {
    @Published var featuresDidUpdate = false
    
    var features: [BetaFeature]? {
        return Current.remoteConfig.configFile?.beta?.features
    }

    var shouldShowInSettings: Bool {
        return userIsBetaUser
    }
    
    func getFeaturesFromRemoteConfig() {
        // TODO: Should this be called on each remote config fetch?
        setupFeatures()
    }

    private var userIsBetaUser: Bool {
        let UID = Current.userManager.currentUserId ?? ""
        let betaUsers = Current.remoteConfig.configFile?.beta?.users
        return betaUsers?.contains(where: { $0.uid == UID }) ?? false
    }

    func isFeatureEnabled(_ featureType: FeatureType, merchant: String? = nil) -> Bool {
        let feature = features?.first(where: { $0.type == featureType })
        
        if let enabledMerchants = feature?.enabledMerchants, let merchant = merchant {
            return enabledMerchants.contains(merchant)
        }
        
        return feature?.isEnabled ?? false
    }

    
    func toggle(_ feature: BetaFeature, enabled: Bool) {
        switch feature.type {
        case .themes:
            let theme = Theme(type: enabled ? .system : .light)
            Current.themeManager.setTheme(theme)
            Current.userDefaults.set(theme.type.rawValue, forDefaultsKey: .theme)
        default:
            break
        }
        
        feature.storeToUserDefaults(enabled)
        featuresDidUpdate = true
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
