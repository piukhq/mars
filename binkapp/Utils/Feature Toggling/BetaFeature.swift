//
//  BetaFeature.swift
//  binkapp
//
//  Created by Sean Williams on 26/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum FeatureType: String, Codable {
    case themes
}

struct BetaFeature: Codable, Identifiable {
    let id = UUID()
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
