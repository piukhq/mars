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
    var data: [String: Any]? { get }
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
    
    var data: [String: Any]? {
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
    
    var data: [String : Any]? {
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
    case addLoyaltyCardResponseSuccess(loyaltyCard: CD_MembershipCard, formPurpose: FormPurpose, statusCode: Int)
    case addLoyaltyCardResponseFail(request: MembershipCardPostModel, formPurpose: FormPurpose)
    
    case addPaymentCardRequest(request: PaymentCardCreateModel)
    case addPaymentCardResponseSuccess(request: PaymentCardCreateModel, paymentCard: CD_PaymentCard, statusCode: Int)
    case addPaymentCardResponseFail(request: PaymentCardCreateModel)
    
    case deleteLoyaltyCard(card: WalletCard)
    case deleteLoyaltyCardResponseSuccess(card: TrackableWalletCard?)
    case deleteLoyaltyCardResponseFail(card: TrackableWalletCard?)
    
    case deletePaymentCard(card: WalletCard)
    case deletePaymentCardResponseSuccess(card: TrackableWalletCard?)
    case deletePaymentCardResponseFail(card: TrackableWalletCard?)
    
    case loyaltyCardStatus(loyaltyCard: CD_MembershipCard)
    
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
        case .addLoyaltyCardResponseSuccess:
            return "add-loyalty-card-response-success"
        case .addLoyaltyCardResponseFail:
            return "add-loyalty-card-response-fail"
        case .addPaymentCardRequest:
            return "add-payment-card-request"
        case .addPaymentCardResponseSuccess:
            return "add-payment-card-response-success"
        case .addPaymentCardResponseFail:
            return "add-payment-card-response-fail"
        case .deleteLoyaltyCard:
            return "delete-loyalty-card"
        case .deleteLoyaltyCardResponseSuccess:
            return "delete-loyalty-card-response-success"
        case .deleteLoyaltyCardResponseFail:
            return "delete-loyalty-card-response-fail"
        case .deletePaymentCard:
            return "delete-payment-card-response"
        case .deletePaymentCardResponseSuccess:
            return "delete-payment-card-response-success"
        case .deletePaymentCardResponseFail:
            return "delete-payment-card-response-fail"
        case .loyaltyCardStatus:
            return "loyalty-card-status"
        }
    }
    
    var data: [String : Any]? {
        switch self {
        case .addLoyaltyCardRequest(let request, let formPurpose):
            guard let planId = request.membershipPlan else { return nil }
            return [
                "loyalty-card-journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client-account-id": request.uuid,
                "loyalty-plan": planId,
                "scanned-card": formPurpose == .addFromScanner ? "true" : "false"
            ]
            
        case .addLoyaltyCardResponseSuccess(let card, let formPurpose, let statusCode):
            guard let uuid = card.uuid else { return nil }
            guard let cardStatus = card.status?.status?.rawValue else { return nil }
            guard let reasonCode = card.status?.formattedReasonCodes?.first?.value else { return nil }
            guard let planIdString = card.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            return [
                "loyalty-card-journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client-account-id": uuid,
                "account-is-new": statusCode == 201 ? "true" : "false",
                "loyalty-status": cardStatus,
                "loyalty-reason-code": reasonCode,
                "loyalty-plan": planId
            ]
            
        case .addLoyaltyCardResponseFail(let request, let formPurpose):
            guard let planId = request.membershipPlan else { return nil }
            return [
                "loyalty-card-journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client-account-id": request.uuid,
                "loyalty-plan": planId
            ]
            
        case .addPaymentCardRequest(let request):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": request.uuid
            ]
            
        case .addPaymentCardResponseSuccess(let request, let card, let statusCode):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            guard let status = card.status else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": request.uuid,
                "account-is-new": statusCode == 201 ? "true" : "false",
                "payment-status": status
            ]
            
        case .addPaymentCardResponseFail(let request):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": request.uuid
            ]
            
        case .deleteLoyaltyCard(let card):
            guard let loyaltyCard = card as? CD_MembershipCard else { return nil }
            guard let planIdString = loyaltyCard.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            guard let uuid = loyaltyCard.uuid else { return nil }
            return [
                "loyalty-plan": planId,
                "client-account-id": uuid
            ]
            
        case .deleteLoyaltyCardResponseSuccess(let card):
            guard let planIdString = card?.loyaltyPlan, let planId = Int(planIdString) else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "loyalty-plan": planId,
                "client-account-id": uuid
            ]
            
        case .deleteLoyaltyCardResponseFail(let card):
            guard let planIdString = card?.loyaltyPlan, let planId = Int(planIdString) else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "loyalty-plan": planId,
                "client-account-id": uuid
            ]
            
        case .deletePaymentCard(let card):
            guard let paymentCard = card as? CD_PaymentCard else { return nil }
            guard let paymentScheme = paymentCard.card?.paymentSchemeIdentifier else { return nil }
            guard let uuid = paymentCard.uuid else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": uuid
            ]
            
        case .deletePaymentCardResponseSuccess(let card):
            guard let paymentScheme = card?.paymentScheme else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": uuid
            ]
            
        case .deletePaymentCardResponseFail(let card):
            guard let paymentScheme = card?.paymentScheme else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "payment-scheme": paymentScheme,
                "client-account-id": uuid
            ]
            
        case .loyaltyCardStatus(let card):
            guard let uuid = card.uuid else { return nil }
            guard let status = card.status?.status?.rawValue else { return nil }
            guard let planIdString = card.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            return [
                "client-account-id": uuid,
                "status": status,
                "loyalty-card-plan": planId
            ]
        }
    }
}
