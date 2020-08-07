//
//  BinkTrackableButton.swift
//  binkapp
//
//  Created by Nick Farrant on 27/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkTrackableButton: UIButton, AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent? {
        guard let identifier = identifier else { return nil }
        return GenericAnalyticsEvent.callToAction(identifier: identifier)
    }

    var additionalTrackingData: [String : Any]?
    private var identifier: String? {
        guard let viewController = viewController() as? BinkTrackableViewController else { return nil }
        guard let screenName = viewController.screenName else { return nil }
        guard let buttonName = titleLabel?.text?.capitalized.replacingOccurrences(of: " ", with: "") else { return nil }
        return "\(screenName).\(buttonName)"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(trackButtonPress), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTarget(self, action: #selector(trackButtonPress), for: .touchUpInside)
    }

    @objc private func trackButtonPress() {
        guard let event = trackableEvent else { return }
        BinkAnalytics.track(event, additionalTrackingData: additionalTrackingData)
    }
}
