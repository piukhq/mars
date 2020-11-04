//
//  InAppReviewUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 04/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import StoreKit

protocol InAppReviewable {
    func requestInAppReview()
}

extension InAppReviewable {
    func requestInAppReview() {
        guard canRequestReview else { return }
        SKStoreReviewController.requestReview()

        // Update last requested time
        let requestedTime = Date().timeIntervalSince1970
        Current.userDefaults.set(requestedTime, forDefaultsKey: .inAppReviewLastRequested)
        
        // Update last minor version
    }

    private var canRequestReview: Bool {
        return requestTimeLimitHasPassed && !reviewRequestedForCurrentMinorVersion && enabledInRemoteConfig
    }

    private var requestTimeLimitHasPassed: Bool {
        if let lastRequestedDefaultsValue = Current.userDefaults.value(forDefaultsKey: .inAppReviewLastRequested) {
            guard let lastRequest = lastRequestedDefaultsValue as? TimeInterval else {
                fatalError("Cannot cast last request value as TimeInterval.")
            }
            let lastRequestDate = Date(timeIntervalSince1970: lastRequest)
            return Date.hasElapsed(days: 7, since: lastRequestDate)
        }

        // The user defaults value has not been set yet, so we are safe to continue.
        return true
    }

    private var reviewRequestedForCurrentMinorVersion: Bool {
        return false
    }

    private var enabledInRemoteConfig: Bool {
        return true
    }
}
