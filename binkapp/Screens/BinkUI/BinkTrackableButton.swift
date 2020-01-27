//
//  BinkTrackableButton.swift
//  binkapp
//
//  Created by Nick Farrant on 27/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BinkTrackableButton: UIButton, AnalyticsTrackable {
    var trackableEvent: BinkAnalyticsEvent {
        return .callToAction(identifier: identifier)
    }

    var additionalTrackingData: [String : Any]?
    var identifier: String {
        guard let viewController = viewController() else { return "" }
        let className = String(describing: type(of: viewController).self)
        let buttonName = titleLabel?.text?.capitalized.replacingOccurrences(of: " ", with: "")
        return "\(className).\(buttonName ?? "")"
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
        BinkAnalytics.track(trackableEvent, additionalTrackingData: additionalTrackingData)
    }
}
