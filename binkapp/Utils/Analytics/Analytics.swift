//
//  Anaytics.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import WidgetKit
import DeepDiff

/// Conformance to this protocol makes a class trackable
protocol AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent? { get }
    var additionalTrackingData: [String: Any]? { get }
}

/// Convenience class wrapping access to the app's current tracking tool.
/// Classes that conform to AnalyticsTrackable should call this method passing their trackableEvent and additionalTrackingData properties
enum BinkAnalytics {
    enum UserPropertyKey: String {
        case osVersion
        case networkStrength
        case deviceZoom
        case binkVersion
        case quicklaunchWidgetInstalled = "ql_widget_installed"
    }

    static let keyPrefix = "com.bink.wallet.trackingSession."
    static let failedWithNoDataEventName = "failed_event_no_data"
    static let attemptedEventName = "attempted_event"

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
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.getCurrentConfigurations { result in
                // Obtain currently installed widget data and map to an array of widget IDs
                if let widgetInfo = try? result.get() {
                    let currentlyInstalledWidgetIDs = widgetInfo.map { $0.kind }

                    // Get previously installed widget IDs from user defaults, if any
                    let previouslyInstalledWidgetIDs = Current.userDefaults.value(forDefaultsKey: .installedWidgetIds) as? [String] ?? []
                    
                    // Compare currently installed widgets to any previously installed widgets
                    let widgetDifferences = diff(old: previouslyInstalledWidgetIDs, new: currentlyInstalledWidgetIDs)
                    
                    if !widgetDifferences.isEmpty || !Current.userDefaults.bool(forDefaultsKey: .hasPreviouslyLaunchedApp) {
                        // We've reached this point if any widgets have been installed or removed since the last app launch, or this is the first ever launch
                        
                        // Loop through the changes, get the IDs and use them to convert to widgetType
                        for change in widgetDifferences {
                            let widgetID = change.insert?.item ?? change.delete?.item ?? ""
                            let widgetType = WidgetType.widgetTypeFromID(widgetID)
                            
                            // Set user property to true or false for each widget installation change
                            switch widgetType {
                            case .quickLaunch:
                                let isQLWidgetInstalled = currentlyInstalledWidgetIDs.contains(widgetID)
                                BinkAnalytics.setUserProperty(value: String(isQLWidgetInstalled), forKey: .quicklaunchWidgetInstalled)
                            default:
                                break
                            }
                        }
                        Current.userDefaults.set(currentlyInstalledWidgetIDs, forDefaultsKey: .installedWidgetIds)
                    }
                }
            }
        }
    }

    private static func setUserProperty(value: String?, forKey key: UserPropertyKey) {
        Analytics.setUserProperty(value, forName: key.rawValue)
    }
}
