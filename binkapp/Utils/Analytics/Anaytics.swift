//
//  Anaytics.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent { get }
    func setAdditionalTrackingData(_ data: [String: Any]?)
}

extension AnalyticsTrackable {
    func setAdditionalTrackingData(_ data: [String: Any]?) {}
}

enum BinkAnalyticsEvent {
    case screenView(screenName: String)
    case callToAction(identifier: String)

    var name: String {
        switch self {
        case .screenView:
            return "screen_viewed"
        case .callToAction:
            return "call_to_action_pressed"
        }
    }

    var data: [String: Any] {
        switch self {
        case .screenView(let screenName):
            return ["screen_name": screenName]
        case .callToAction(let identifier):
            return ["identifier": identifier]
        }
    }
}

struct BinkAnalytics {
    static func track(_ event: BinkAnalyticsEvent, additionalTrackingData: [String: Any]?) {
        var trackingData: [String: Any] = [:]

        defer {
            print("TRACKING // \(event.name) = \(trackingData)")
//            Analytics.logEvent(event.name, parameters: trackingData)
        }

        guard var data = additionalTrackingData else {
            trackingData = event.data
            return
        }

        data.merge(dict: event.data)
        trackingData = data
    }
}
