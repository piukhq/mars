//
//  FeatureTogglingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum FeatureType: String, Codable {
    case darkmode
    case seanmode
    case nickmode
}

struct Feature: Codable {
    let slug: String?
    let type: FeatureType?
    let title: String?
    let description: String?
    let isEnabledOnRemoteConfig: Bool?

    enum CodingKeys: String, CodingKey {
        case slug
        case type
        case title
        case description
        case isEnabledOnRemoteConfig = "enabled"
    }

    var isEnabled: Bool {
        // If a user defaults value is set, return it, otherwise, return the value from remote config
        let userDefaultsFlags = Current.userDefaults.value(forDefaultsKey: .featureFlags) as? [[String: Any]]
        
        for feature in userDefaultsFlags ?? [] {
            if feature["slug"] as? String == slug {
                return feature["enabled"] as? Bool ?? false
            }
        }
        return isEnabledOnRemoteConfig ?? false
    }

    func storeToUserDefaults(_ enabled: Bool) {
        guard var userDefaultsFlags = Current.userDefaults.value(forDefaultsKey: .featureFlags) as? [[String: Any]] else {
            // If there are no flags in user defaults, store this one
            let featureDict = toDictionary(enabled: enabled)
            Current.userDefaults.set([featureDict], forDefaultsKey: .featureFlags)
            return
        }

        // UD flags exist: check if they contain current feature, if yes, update 'enabled' value
        for feature in userDefaultsFlags.indices {
            if userDefaultsFlags[feature]["slug"] as? String == slug {
                userDefaultsFlags[feature]["enabled"] = enabled
                Current.userDefaults.set(userDefaultsFlags, forDefaultsKey: .featureFlags)
                return
            }
        }
        
        // UD flags exist, but not this one, append it
        let featureDict = self.toDictionary(enabled: enabled)
        userDefaultsFlags.append(featureDict)
        Current.userDefaults.set(userDefaultsFlags, forDefaultsKey: .featureFlags)
    }
    
    private func toDictionary(enabled: Bool) -> [String: Any] {
        return [
            "slug": slug ?? "" as String,
            "enabled": enabled
        ]
    }
}

final class FeatureTogglingManager {
    var features: [Feature]? = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)

    var shouldShowInSettings: Bool {
        return userIsBetaUser()
    }
    
    func getFeaturesFromRemoteConfig() {
        features = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)
        setupFeatures()
    }

    private func userIsBetaUser() -> Bool {
        let UID = Current.userManager.currentUserId ?? ""
        let betaUsers = Current.remoteConfig.objectForConfigKey(.betaUsers, forObjectType: [BetaUser].self)
        return betaUsers?.contains(where: { $0.uid == UID }) ?? false
    }

    func isFeatureEnabled(_ featureType: FeatureType) -> Bool {
        let feature = features?.first(where: { $0.type == featureType })
        return feature?.isEnabled ?? false
    }

    
    func toggle(_ feature: Feature?, enabled: Bool, shouldStore: Bool = true) {
        switch feature?.type {
        case .darkmode:
            Current.themeManager.setTheme(Theme(type: enabled ? .system : .light))
        default:
            break
        }
        
        // If beta user has toggled, store value in user defaults
        if shouldStore {
            feature?.storeToUserDefaults(enabled)
        }
    }
    
    func setupFeature(_ feature: Feature?, enabled: Bool) {
        switch feature?.type {
        case .darkmode:
            Current.themeManager.applyPreferredTheme()
        default:
            break
        }
    }
    
    func setupFeatures() {
        features?.forEach {
            setupFeature($0, enabled: $0.isEnabled)
        }
    }
}

struct BetaUser: Codable {
    let uid: String
}
