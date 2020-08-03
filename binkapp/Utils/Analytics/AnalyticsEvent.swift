//
//  AnalyticsEvent.swift
//  binkapp
//
//  Created by Nick Farrant on 03/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation
import FirebaseAnalytics

protocol BinkAnalyticsEvent {
    var name: String { get }
    var data: [String: Any] { get }
}

// MARK: - Generic events
enum GenericAnalyticsEvent: BinkAnalyticsEvent {
    case callToAction(identifier: String)
    case paymentScan(success: Bool)
    
    var name: String {
        switch self {
        case .callToAction:
            return "call_to_action_pressed"
        case .paymentScan:
            return "payment_scan"
        }
    }
    
    var data: [String: Any] {
        switch self {
        case .callToAction(let identifier):
            return ["identifier": identifier]
        case .paymentScan(let success):
            let value = NSNumber(value: success)
            return ["success": value, AnalyticsParameterValue: value]
        }
    }
}

// MARK: - Onboarding events

enum OnboardingAnalyticsEvent: BinkAnalyticsEvent {
    case start
    case userComplete
    case serviceComplete
    case end
    
    var name: String {
        switch self {
        case .start:
            return "onboarding-start"
        case .userComplete:
            return "onboarding-user-compelete"
        case .serviceComplete:
            return "onboarding-service-complete"
        case .end:
            return "onboarding-end"
        }
    }
    
    var data: [String : Any] {
        return ["": ""]
    }
}
