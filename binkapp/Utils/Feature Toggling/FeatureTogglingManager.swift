//
//  FeatureTogglingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

struct Feature: Codable {
    let slug: String?
    let title: String?
    let description: String?
    let isEnabledOnRemoteConfig: Bool?

    enum CodingKeys: String, CodingKey {
        case slug
        case title
        case description
        case isEnabledOnRemoteConfig = "isEnabled"
    }

    var isEnabled: Bool {
        // Is there a user defaults value set? If so, return it, otherwise, return the value from remote config
        let userDefaultsFlags = Current.userDefaults.value(forDefaultsKey: .featureFlags) as? [[String: Any]]
        
        for feature in userDefaultsFlags ?? [] {
            if feature["slug"] as? String == slug {
                return feature["enabled"] as? Bool ?? false
            }
        }
        return isEnabledOnRemoteConfig ?? false
    }

    func toggle(isOn: Bool) {
        guard var userDefaultsFlags = Current.userDefaults.value(forDefaultsKey: .featureFlags) as? [[String: Any]] else {
            // If there are no flags in user defaults, store this one
            let featureDict = toDictionary(enabled: isOn)
            Current.userDefaults.set([featureDict], forDefaultsKey: .featureFlags)
            return
        }

        // If there are UD flags, Loop through flags and see if it contains current feature
        for feature in userDefaultsFlags.indices {
            if userDefaultsFlags[feature]["slug"] as? String == slug {
                userDefaultsFlags[feature]["enabled"] = isOn
                Current.userDefaults.set(userDefaultsFlags, forDefaultsKey: .featureFlags)
                return
            }
        }
        
        // There are UD flags but not this one, append it
        let featureDict = self.toDictionary(enabled: isOn)
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
    // Has the user toggled the feature?

    var shouldShowInSettings: Bool {
        return userIsEligible()
    }

    private func userIsEligible() -> Bool {
        let UID = Current.userManager.currentUserId ?? ""
        let betaUsers = Current.remoteConfig.objectForConfigKey(.betaUsers, forObjectType: [BetaUser].self)
        return betaUsers?.contains(where: { $0.uid == UID }) ?? false
    }

    func isFeatureEnabled(_ feature: Feature) -> Bool {
        return feature.isEnabled
    }

//    func toggle(_ feature: Feature) {
//        feature.toggle()
//    }
}

struct BetaUser: Codable {
    let uid: String
}
