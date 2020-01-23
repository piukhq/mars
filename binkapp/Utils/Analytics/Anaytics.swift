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
}

enum BinkAnalyticsEvent {
    case screenView(screenName: String)
    case callToAction(identifier: String)

    var name: String {
        switch self {
        case .screenView:
            return "screenView"
        case .callToAction:
            return "callToAction"
        }
    }

    var data: [String: Any]? {
        switch self {
        case .screenView(let screenName):
            return ["screenName": screenName]
        case .callToAction(let identifier):
            return ["identifier": identifier]
        }
    }
}

struct BinkAnalytics {
    static func track(_ event: BinkAnalyticsEvent) {
        print("TRACKING \(event.name): \(event.data ?? [:])")
//        Analytics.logEvent(event.name, parameters: event.data)
    }
}

extension UIViewController: AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent {
        let className = String(describing: Self.self)
        return .screenView(screenName: className)
    }
}
