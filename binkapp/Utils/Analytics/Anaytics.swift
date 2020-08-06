//
//  Anaytics.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics

/// Conformance to this protocol makes a class trackable
protocol AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent? { get }
    var additionalTrackingData: [String: Any]? { get }
}

/// Convenience class wrapping access to the app's current tracking tool.
/// Classes that conform to AnalyticsTrackable should call this method passing their trackableEvent and additionalTrackingData properties
struct BinkAnalytics {
    enum UserPropertyKey: String {
        case osVersion
        case networkStrength
        case deviceZoom
        case binkVersion
    }

    static let keyPrefix = "com.bink.wallet.trackingSession."
    static let failedWithNoDataEventName = "failed-event-no-data"
    static let attemptedEventName = "attempted-event"

    static func track(_ event: BinkAnalyticsEvent, additionalTrackingData: [String: Any]? = nil) {
        #if RELEASE
        var trackingData: [String: Any]?

        defer {
            if trackingData == nil {
                Analytics.logEvent(BinkAnalytics.failedWithNoDataEventName, parameters: [BinkAnalytics.attemptedEventName: event.name])
            } else {
                Analytics.logEvent(event.name, parameters: trackingData)
            }
        }

        // Do we have additional tracking data?
        guard var data = additionalTrackingData else {
            // No, just use the event data
            trackingData = event.data
            return
        }

        // We have additional tracking data. If we have event data, merge the 2
        if let eventData = event.data {
            data.merge(dict: eventData)
            trackingData = data
        }
        
        // Otherwise just track the additional data
        trackingData = data
        #endif
    }

    static func beginSessionTracking() {
        BinkAnalytics.setUserProperty(value: UIDevice.current.systemVersion, forKey: .osVersion)
        BinkAnalytics.setUserProperty(value: Current.apiClient.networkStrength.rawValue, forKey: .networkStrength)

        let standardZoom: Bool = UIScreen.main.nativeScale == UIScreen.main.scale
        BinkAnalytics.setUserProperty(value: "\(standardZoom ? "standard" : "zoomed")", forKey: .deviceZoom)

        guard let appVersion = Bundle.shortVersionNumber else { return }
        guard let buildNumber = Bundle.bundleVersion else { return }
        BinkAnalytics.setUserProperty(value: "Version: \(appVersion), build: \(buildNumber)", forKey: .binkVersion)
    }

    private static func setUserProperty(value: String?, forKey key: UserPropertyKey) {
        Analytics.setUserProperty(value, forName: key.rawValue)
    }
}
