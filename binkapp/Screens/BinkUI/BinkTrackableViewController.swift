//
//  BinkTrackableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class BinkTrackableViewController: UIViewController, AnalyticsTrackable {
    /// Optional additional data to pass to analytics along with the default tracking event data
    var additionalTrackingData: [String: Any]?

    /// Set the trackable event for all subclassing view controllers
    var trackableEvent: BinkAnalyticsEvent {
        let className = String(describing: Self.self)
        return .screenView(screenName: className)
    }
    
    func setScreenName(trackedScreen: TrackedScreensEnum) {
        Analytics.setScreenName(trackedScreen.rawValue, screenClass: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /// Disabling in favour of Firebase's out-of-the-box screen name tracking
//        BinkAnalytics.track(trackableEvent, additionalTrackingData: additionalTrackingData)
    }
}
