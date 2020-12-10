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
            return "onboarding_start"
        case .userComplete:
            return "onboarding_user_complete"
        case .serviceComplete:
            return "onboarding_service_complete"
        case .end:
            return "onboarding_end"
        }
    }
    
    var data: [String: Any]? {
        switch self {
        case .start(let journey):
            Current.onboardingTrackingId = UUID().uuidString
            guard let onboardingId = Current.onboardingTrackingId else { return nil }
            return [
                "onboarding_id": onboardingId,
                "onboarding_journey": journey.rawValue
            ]
        case .end(let didSucceed):
            guard let onboardingId = Current.onboardingTrackingId else { return nil }
            return [
                "onboarding_id": onboardingId,
                "onboarding_success": didSucceed ? "true" : "false"
            ]
        default:
            guard let onboardingId = Current.onboardingTrackingId else { return nil }
            return [
                "onboarding_id": onboardingId
            ]
        }
    }
}

// MARK: - Card account events

enum CardAccountAnalyticsEvent: BinkAnalyticsEvent {
    case addLoyaltyCardRequest(request: MembershipCardPostModel, formPurpose: FormPurpose)
    case addLoyaltyCardResponseSuccess(loyaltyCard: CD_MembershipCard, formPurpose: FormPurpose, statusCode: Int)
    case addLoyaltyCardResponseFail(request: MembershipCardPostModel, formPurpose: FormPurpose, responseData: NetworkResponseData?)
    
    case addPaymentCardRequest(request: PaymentCardCreateModel)
    case addPaymentCardResponseSuccess(request: PaymentCardCreateModel, paymentCard: CD_PaymentCard, statusCode: Int)
    case addPaymentCardResponseFail(request: PaymentCardCreateModel, responseData: NetworkResponseData?)
    
    case deleteLoyaltyCard(card: WalletCard)
    case deleteLoyaltyCardResponseSuccess(card: TrackableWalletCard?)
    case deleteLoyaltyCardResponseFail(card: TrackableWalletCard?, responseData: NetworkResponseData?)
    
    case deletePaymentCard(card: WalletCard)
    case deletePaymentCardResponseSuccess(card: TrackableWalletCard?)
    case deletePaymentCardResponseFail(card: TrackableWalletCard?, responseData: NetworkResponseData?)
    
    case loyaltyCardStatus(loyaltyCard: CD_MembershipCard, newStatus: MembershipCardStatus?)
    case paymentCardStatus(paymentCard: CD_PaymentCard, newStatus: String?)
    
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
            return "add_loyalty_card_request"
        case .addLoyaltyCardResponseSuccess:
            return "add_loyalty_card_response_success"
        case .addLoyaltyCardResponseFail:
            return "add_loyalty_card_response_fail"
        case .addPaymentCardRequest:
            return "add_payment_card_request"
        case .addPaymentCardResponseSuccess:
            return "add_payment_card_response_success"
        case .addPaymentCardResponseFail:
            return "add_payment_card_response_fail"
        case .deleteLoyaltyCard:
            return "delete_loyalty_card_request"
        case .deleteLoyaltyCardResponseSuccess:
            return "delete_loyalty_card_response_success"
        case .deleteLoyaltyCardResponseFail:
            return "delete_loyalty_card_response_fail"
        case .deletePaymentCard:
            return "delete_payment_card_request"
        case .deletePaymentCardResponseSuccess:
            return "delete_payment_card_response_success"
        case .deletePaymentCardResponseFail:
            return "delete_payment_card_response_fail"
        case .loyaltyCardStatus:
            return "loyalty_card_status"
        case .paymentCardStatus:
            return "payment_card_status"
        }
    }
    
    var data: [String: Any]? {
        switch self {
        case .addLoyaltyCardRequest(let request, let formPurpose):
            guard let planId = request.membershipPlan else { return nil }
            return [
                "loyalty_card_journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client_account_id": request.uuid,
                "loyalty_plan": planId,
                "scanned_card": formPurpose == .addFromScanner ? "true" : "false"
            ]
            
        case .addLoyaltyCardResponseSuccess(let card, let formPurpose, let statusCode):
            guard let uuid = card.uuid else { return nil }
            guard let cardStatus = card.status?.status?.rawValue else { return nil }
            guard let reasonCode = card.status?.formattedReasonCodes?.first?.rawValue else { return nil }
            guard let planIdString = card.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            return [
                "loyalty_card_journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client_account_id": uuid,
                "account_is_new": statusCode == 201 ? "true" : "false",
                "loyalty_status": cardStatus,
                "loyalty_reason_code": reasonCode,
                "loyalty_plan": planId
            ]
            
        case .addLoyaltyCardResponseFail(let request, let formPurpose, let responseData):
            guard let planId = request.membershipPlan else { return nil }
            guard let statusCode = responseData?.urlResponse?.statusCode else { return nil }
            return [
                "loyalty_card_journey": LoyaltyCardAccountJourney.journey(for: formPurpose).rawValue,
                "client_account_id": request.uuid,
                "loyalty_plan": planId,
                "error_code": statusCode,
                "error_message": responseData?.errorMessage ?? "Error message not provided"
            ]
            
        case .addPaymentCardRequest(let request):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": request.uuid
            ]
            
        case .addPaymentCardResponseSuccess(let request, let card, let statusCode):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            guard let status = card.status else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": request.uuid,
                "account_is_new": statusCode == 201 ? "true" : "false",
                "payment_status": status
            ]
            
        case .addPaymentCardResponseFail(let request, let responseData):
            guard let paymentScheme = request.cardType?.paymentSchemeIdentifier else { return nil }
            guard let statusCode = responseData?.urlResponse?.statusCode else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": request.uuid,
                "error_code": statusCode,
                "error_message": responseData?.errorMessage ?? "Error message not provided"
            ]
            
        case .deleteLoyaltyCard(let card):
            guard let loyaltyCard = card as? CD_MembershipCard else { return nil }
            guard let planIdString = loyaltyCard.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            guard let uuid = loyaltyCard.uuid else { return nil }
            return [
                "loyalty_plan": planId,
                "client_account_id": uuid
            ]
            
        case .deleteLoyaltyCardResponseSuccess(let card):
            guard let planIdString = card?.loyaltyPlan, let planId = Int(planIdString) else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "loyalty_plan": planId,
                "client_account_id": uuid
            ]
            
        case .deleteLoyaltyCardResponseFail(let card, let responseData):
            guard let planIdString = card?.loyaltyPlan, let planId = Int(planIdString) else { return nil }
            guard let uuid = card?.uuid else { return nil }
            guard let statusCode = responseData?.urlResponse?.statusCode else { return nil }
            return [
                "loyalty_plan": planId,
                "client_account_id": uuid,
                "error_code": statusCode,
                "error_message": responseData?.errorMessage ?? "Error message not provided"
            ]
            
        case .deletePaymentCard(let card):
            guard let paymentCard = card as? CD_PaymentCard else { return nil }
            guard let paymentScheme = paymentCard.card?.paymentSchemeIdentifier else { return nil }
            guard let uuid = paymentCard.uuid else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": uuid
            ]
            
        case .deletePaymentCardResponseSuccess(let card):
            guard let paymentScheme = card?.paymentScheme else { return nil }
            guard let uuid = card?.uuid else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": uuid
            ]
            
        case .deletePaymentCardResponseFail(let card, let responseData):
            guard let paymentScheme = card?.paymentScheme else { return nil }
            guard let uuid = card?.uuid else { return nil }
            guard let statusCode = responseData?.urlResponse?.statusCode else { return nil }
            return [
                "payment_scheme": paymentScheme,
                "client_account_id": uuid,
                "error_code": statusCode,
                "error_message": responseData?.errorMessage ?? "Error message not provided"
            ]
            
        case .loyaltyCardStatus(let card, let status):
            guard let uuid = card.uuid else { return nil }
            guard let status = status?.rawValue else { return nil }
            guard let planIdString = card.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            return [
                "client_account_id": uuid,
                "status": status,
                "loyalty_card_plan": planId
            ]
            
        case .paymentCardStatus(let card, let status):
            guard let uuid = card.uuid else { return nil }
            guard let status = status else { return nil }
            guard let paymentScheme = card.card?.paymentSchemeIdentifier else { return nil }
            return [
                "client_account_id": uuid,
                "status": status,
                "payment_scheme": paymentScheme
            ]
        }
    }
}

enum PLLAnalyticsEvent: BinkAnalyticsEvent {
    case pllPatch(loyaltyCard: CD_MembershipCard, paymentCard: CD_PaymentCard, response: PaymentCardModel?)
    case pllDelete(loyaltyCard: CD_MembershipCard, paymentCard: CD_PaymentCard)
    case pllActive(loyaltyCard: CD_MembershipCard, paymentCard: CD_PaymentCard)
    
    enum PLLState: String {
        case active = "ACTIVE"
        case failed = "FAILED"
        case softLink = "SOFT-LINK"
    }
    
    var name: String {
        switch self {
        case .pllPatch:
            return "pll_patch"
        case .pllDelete:
            return "pll_delete"
        case .pllActive:
            return "pll_active"
        }
    }
    
    var data: [String: Any]? {
        switch self {
        case .pllPatch(let loyaltyCard, let paymentCard, let response):
            guard let paymentId = paymentCard.uuid else { return nil }
            guard let loyaltyId = loyaltyCard.uuid else { return nil }
            return [
                "payment_id": paymentId,
                "loyalty_id": loyaltyId,
                "link_id": "\(loyaltyId)/\(paymentId)",
                "state": pllState(response: response, loyaltyCard: loyaltyCard).rawValue
            ]
        case .pllDelete(let loyaltyCard, let paymentCard):
            guard let paymentId = paymentCard.uuid else { return nil }
            guard let loyaltyId = loyaltyCard.uuid else { return nil }
            return [
                "payment_id": paymentId,
                "loyalty_id": loyaltyId,
                "link_id": "\(loyaltyId)/\(paymentId)"
            ]
            
        case .pllActive(let loyaltyCard, paymentCard: let paymentCard):
            guard let paymentId = paymentCard.uuid else { return nil }
            guard let loyaltyId = loyaltyCard.uuid else { return nil }
            return [
                "payment_id": paymentId,
                "loyalty_id": loyaltyId,
                "link_id": "\(loyaltyId)/\(paymentId)"
            ]
        }
    }
    
    private func pllState(response: PaymentCardModel?, loyaltyCard: CD_MembershipCard) -> PLLState {
        // If we have a response, we know the API call returned a 200 so the state must be active or soft-link
        guard let response = response else { return .failed }
        
        // If the response contains a linked membership card with the id we attempted to patch, the state is active
        if let loyaltyId = Int(loyaltyCard.id), response.membershipCards?.contains(where: { $0.id == loyaltyId }) == true {
            return .active
        }
        return .softLink
    }
}

enum LocalPointsCollectionEvent: BinkAnalyticsEvent {
    case localPointsCollectionSuccess(membershipCard: CD_MembershipCard)
    case localPointsCollectionStatus(membershipCard: CD_MembershipCard)
    case localPointsCollectionInternalFailure(membershipCard: CD_MembershipCard, error: WebScrapingUtilityError)
    case localPointsCollectionCredentialFailure(membershipCard: CD_MembershipCard, error: WebScrapingUtilityError)
    
    var name: String {
        switch self {
        case .localPointsCollectionSuccess:
            return "local_points_collection_balance_success"
        case .localPointsCollectionStatus:
            return "local_points_collection_status"
        case .localPointsCollectionInternalFailure:
            return "local_points_collection_internal_failure"
        case .localPointsCollectionCredentialFailure:
            return "local_points_collection_credential_failure"
        }
    }
    
    var data: [String: Any]? {
        switch self {
        case .localPointsCollectionSuccess(let membershipCard):
            guard let planIdString = membershipCard.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            guard let uuid = membershipCard.uuid else { return nil }
            return [
                "loyalty_plan": planId,
                "client_account_id": uuid
            ]
        case .localPointsCollectionStatus(let membershipCard):
            guard let planIdString = membershipCard.membershipPlan?.id, let planId = Int(planIdString) else { return nil }
            guard let uuid = membershipCard.uuid else { return nil }
            guard let status = membershipCard.status?.status?.rawValue else { return nil }
            return [
                "loyalty_plan": planId,
                "status": status,
                "client_account_id": uuid
            ]
        case .localPointsCollectionInternalFailure(let membershipCard, let error):
            guard let uuid = membershipCard.uuid else { return nil }
            return [
                "client_account_id": uuid,
                "error_string": error.message
            ]
        case .localPointsCollectionCredentialFailure(let membershipCard, let error):
            guard let uuid = membershipCard.uuid else { return nil }
            return [
                "client_account_id": uuid,
                "error_string": error.message
            ]
        }
    }
}

enum InAppReviewAnalyticsEvent: BinkAnalyticsEvent {
    case add
    case transactions
    case time

    var name: String {
        return "in_app_review_request"
    }

    var data: [String: Any]? {
        switch self {
        case .add:
            return [
                "review_trigger": "ADD"
            ]
        case .transactions:
            return [
                "review_trigger": "TRANSACTIONS"
            ]
        case .time:
            return [
                "review_trigger": "TIME"
            ]
        }
    }

    static var eventForInProgressJourney: InAppReviewAnalyticsEvent? {
        if let _ = Current.inAppReviewableJourney as? PllLoyaltyInAppReviewableJourney {
            return InAppReviewAnalyticsEvent.add
        }
        if let _ = Current.inAppReviewableJourney as? TransactionsHistoryInAppReviewableJourney {
            return InAppReviewAnalyticsEvent.transactions
        }
        if let _ = Current.inAppReviewableJourney as? TimeAndUsageBasedInAppReviewableJourney {
            return InAppReviewAnalyticsEvent.time
        }
        return nil
    }
}

// MARK: - Dynamic actions

enum DynamicActionsAnalyticsEvent: BinkAnalyticsEvent {
    case triggered(DynamicAction)

    var name: String {
        return "dynamic_action_triggered"
    }

    var data: [String : Any]? {
        switch self {
        case .triggered(let action):
            guard let actionName = action.name else { return nil }
            return [
                "dynamic_action_name": actionName
            ]
        }
    }
}
