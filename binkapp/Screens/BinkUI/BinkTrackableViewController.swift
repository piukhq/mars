//
//  BinkTrackableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkTrackableViewController: UIViewController {
    private var additionalTrackingData: [String: Any]?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BinkAnalytics.track(trackableEvent, additionalTrackingData: additionalTrackingData)
    }

    func setAdditionalTrackingData(_ data: [String: Any]?) {
        additionalTrackingData = data
    }
}

extension BinkTrackableViewController: AnalyticsTrackable {
    /// Set the trackable event for all subclassing view controllers
    var trackableEvent: BinkAnalyticsEvent {
        let className = String(describing: Self.self)
        return .screenView(screenName: className)
    }
}
