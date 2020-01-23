//
//  Anaytics.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import FirebaseAnalytics

protocol AnalyticsTrackable {
    func track(_ event: AnalyticsEvent)
}

enum AnalyticsEvent {
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
