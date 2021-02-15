//
//  FeatureTogglingManager.swift
//  binkapp
//
//  Created by Nick Farrant on 12/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

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
        // Is there a user defaults value set? If so, return it
        // Otherwise, return the value from remote config
        return isEnabledOnRemoteConfig ?? false
    }

    func toggle() {
        // Get the user default value
        // Store a toggled representation of the user default value
        // If there is no user default value, get the remote config value
        // Store a toggled representation of the remote config value
    }
}

final class FeatureTogglingManager {

    // Has the user toggled the feature?

    // Is the user enrolled in feature toggling?

    // Show feature toggling in settings if necessary

    var shouldShowInSettings: Bool {
        return userIsEligible()
    }

    private func userIsEligible() -> Bool {
        return false
    }

    func isFeatureEnabled(_ feature: Feature) -> Bool {
        return feature.isEnabled
    }

    func toggle(_ feature: Feature) {
        feature.toggle()
    }
}

class FeatureToggleViewModel {
    private let features = Current.remoteConfig.objectForConfigKey(.betaFeatures, forObjectType: [Feature].self)
}
