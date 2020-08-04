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
    case start(journey: Journey)
    case userComplete
    case serviceComplete
    case end(didSucceed: Bool)
    
    enum Journey: String {
        case login = "LOGIN"
        case register = "REGISTER"
        case apple = "APPLE"
        case facebook = "FACEBOOK"
    }
    
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
        switch self {
        case .start(let journey):
            Current.onboardingTrackingId = UUID().uuidString
            guard let onboardingId = Current.onboardingTrackingId else {
                fatalError("Onboarding tracking id not found.")
            }
            return ["onboarding-id": onboardingId, "onboarding-journey": journey.rawValue]
        case .end(let didSucceed):
            guard let onboardingId = Current.onboardingTrackingId else {
                fatalError("Onboarding tracking id not found.")
            }
            return ["onboarding-id": onboardingId, "onboarding-succeess": didSucceed ? "true" : "false"]
        default:
            guard let onboardingId = Current.onboardingTrackingId else {
                fatalError("Onboarding tracking id not found.")
            }
            return ["onboarding-id": onboardingId]
        }
    }
}

// MARK: - Card account events

enum CardAccountAnalyticsEvent: BinkAnalyticsEvent {
    case addLoyaltyCardRequest(request: MembershipCardPostModel, formPurpose: FormPurpose)
    
    enum LoyaltyCardAccountJourney: String {
        case add = "ADD"
        case enrol = "ENROL"
        case register = "REGISTER"
        
        static func journey(for formPurpose: FormPurpose) -> LoyaltyCardAccountJourney {
            switch formPurpose {
            case .add, .addFailed, .addFromScanner:
                return .add
            case .signUp, .signUpFailed:
                return .enrol
            case .ghostCard, .patchGhostCard:
                return .register
            }
        }
    }
    
    var name: String {
        switch self {
        case .addLoyaltyCardRequest:
            return "add-loyalty-card-request"
        }
    }
    
    var data: [String : Any] {
        switch self {
        case .addLoyaltyCardRequest(let request, let formPurpose):
            guard let planId = request.membershipPlan else { fatalError("No plan id") }
            return [
                "loyalty-card-journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client-account-id": request.uuid,
                "loyalty-plan": planId,
                "scanned-card": formPurpose == .addFromScanner ? "true" : "false"
            ]
        }
    }
}
