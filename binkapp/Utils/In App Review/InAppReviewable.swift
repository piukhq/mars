//
//  InAppReviewable.swift
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
        defer {
            Current.inAppReviewableJourney = nil
        }
        
        guard canRequestReview else { return }
        SKStoreReviewController.requestReview()
        if let event = InAppReviewAnalyticsEvent.eventForInProgressJourney {
            if #available(iOS 14.0, *) {
                let data = event.data as? [String: String]
                let trigger = data?["review_trigger"]
                BinkLogger.info(event: AppLoggerEvent.requestedInAppReview, value: trigger)
            }
            BinkAnalytics.track(event)
        }
        setUpdatedRequestTime()
        setUpdatedRequestedMinorVersions()
    }

    private var canRequestReview: Bool {
        #if DEBUG
        guard Current.userDefaults.bool(forDefaultsKey: .applyInAppReviewRules) else { return true }
        #endif
        return requestTimeLimitHasPassed && !reviewRequestedForCurrentMinorVersion && enabledInRemoteConfig
    }

    private var requestTimeLimitHasPassed: Bool {
        /// Can we get a user defaults value for the last request time?
        if let lastRequestedDefaultsValue = Current.userDefaults.value(forDefaultsKey: .inAppReviewLastRequestedDate) {
            guard let lastRequest = lastRequestedDefaultsValue as? TimeInterval else {
                /// We have a user defaults value, but it is of the wrong type. Fatal error to be fixed.
                fatalError("Cannot cast last request value as TimeInterval.")
            }
            /// Has it been 7 days since we last requested a review?
            let lastRequestDate = Date(timeIntervalSince1970: lastRequest)
            return Date.hasElapsed(days: 7, since: lastRequestDate)
        }

        // The user defaults value has not been set yet, so we are safe to continue.
        return true
    }

    private var reviewRequestedForCurrentMinorVersion: Bool {
        /// Can we identify the current minor version?
        guard let currentMinorVersion = Bundle.minorVersion else {
            fatalError("Could not read minor version.")
        }

        /// Can we get a user defaults value for the minor versions that previously displayed requests?
        if let requestedMinorVersionsDefaultsValues = Current.userDefaults.value(forDefaultsKey: .inAppReviewRequestedMinorVersions) {
            guard let requestedMinorVersions = requestedMinorVersionsDefaultsValues as? [Int] else {
                /// We have a user defaults value, but it is of the wrong type. Fatal error to be fixed.
                fatalError("Cannot cast last request minor version as array of integers.")
            }
            /// Have we requested a review for the current minor version before?
            return requestedMinorVersions.contains(currentMinorVersion)
        }

        // The user defaults value has not been set yet, so we are safe to continue.
        return false
    }

    private var enabledInRemoteConfig: Bool {
        return Current.remoteConfig.boolValueForConfigKey(.inAppReviewEnabled)
    }

    private func setUpdatedRequestTime() {
        let requestedTime = Date().timeIntervalSince1970
        Current.userDefaults.set(requestedTime, forDefaultsKey: .inAppReviewLastRequestedDate)
    }

    private func setUpdatedRequestedMinorVersions() {
        guard let currentMinorVersion = Bundle.minorVersion else { return }
        let requestedMinorVersionsDefaultsValues = Current.userDefaults.value(forDefaultsKey: .inAppReviewRequestedMinorVersions)
        var requestedMinorVersions = requestedMinorVersionsDefaultsValues as? [Int]
        requestedMinorVersions?.append(currentMinorVersion)

        /// Update the existing list of minor versions, or create a new list with the current minor version.
        Current.userDefaults.set(requestedMinorVersions ?? [currentMinorVersion], forDefaultsKey: .inAppReviewRequestedMinorVersions)
    }
}
