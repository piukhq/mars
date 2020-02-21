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
    var trackableEvent: BinkAnalyticsEvent { get }
    var additionalTrackingData: [String: Any]? { get }
}

/// Events that can be tracked across the app
enum BinkAnalyticsEvent {
    case callToAction(identifier: String)

    var name: String {
        switch self {
        case .callToAction:
            return "call_to_action_pressed"
        }
    }

    var data: [String: Any] {
        switch self {
        case .callToAction(let identifier):
            return ["identifier": identifier]
        }
    }
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

    static func track(_ event: BinkAnalyticsEvent, additionalTrackingData: [String: Any]?) {
        var trackingData: [String: Any] = [:]

        defer {
            #if RELEASE
            Analytics.logEvent(event.name, parameters: trackingData)
            #endif
        }

        guard var data = additionalTrackingData else {
            trackingData = event.data
            return
        }

        data.merge(dict: event.data)
        trackingData = data
    }

    static func beginSessionTracking() {
        BinkAnalytics.setUserProperty(value: UIDevice.current.systemVersion, forKey: .osVersion)
        BinkAnalytics.setUserProperty(value: Current.apiManager.networkStrength.rawValue, forKey: .networkStrength)

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
