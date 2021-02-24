//
//  FeatureTogglingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

enum FeatureType: String, Codable {
    case DarkMode
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
        case isEnabledOnRemoteConfig = "isEnabled"
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

    func toggle(_ enabled: Bool) {
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
        
        // If there is no user default value, get the remote config value
        // Store a toggled representation of the remote config value
    }
    
    private func toDictionary(enabled: Bool) -> [String: Any] {
        return [
            "slug": slug ?? "" as String,
            "enabled": enabled
        ]
    }
}

final class FeatureTogglingManager {
    let features = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)

    var shouldShowInSettings: Bool {
        return userIsEligible()
    }

    private func userIsEligible() -> Bool {
        let UID = Current.userManager.currentUserId ?? ""
        let betaUsers = Current.remoteConfig.objectForConfigKey(.betaUsers, forObjectType: [BetaUser].self)
        return betaUsers?.contains(where: { $0.uid == UID }) ?? false
    }

    func isFeatureEnabled(_ featureType: FeatureType) -> Bool {
        let feature = features?.first(where: { $0.type == featureType })
        return feature?.isEnabled ?? false
    }

    func toggle(_ feature: Feature?, enabled: Bool) {
        switch feature?.type {
        case .DarkMode:
            Current.themeManager.setTheme(Theme(type: enabled ? .system : .light))
        case .seanmode:
            print("SEAAAAAAAANNNNNNNNNN")
        case .nickmode:
            print("NIIIIIIIICKKKKKKKKKK")
        default:
            break
        }
        
        feature?.toggle(enabled)
    }
}

struct BetaUser: Codable {
    let uid: String
}
