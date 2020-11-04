//
//  InAppReviewUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 04/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

//enum InAppReviewableJourneyError: BinkError {
//    case journeyAlreadyInProgress(InAppReviewableJourney)
//    case journeyNotEligibleForInAppReview(InAppReviewableJourney)
//    case journeyMismatch(inProgress: InAppReviewableJourney, inContext: InAppReviewableJourney)
//    case noJourneyFound
//
//    var domain: BinkErrorDomain {
//        return .inAppReviewableJourney
//    }
//
//    var message: String {
//        switch self {
//        case .journeyAlreadyInProgress(let journey):
//            return "Journey already in progress: \(journey.identifier)"
//        case .journeyNotEligibleForInAppReview(let journey):
//            return "Journey not eligible for in app review: \(journey.identifier)"
//        case .journeyMismatch(let inProgress, let inContext):
//            return "Attempted to end \(inContext.identifier), however \(inProgress.identifier) is currently in progress. This should never be the case."
//        case .noJourneyFound:
//            return "No journey in progress. This should never happen."
//        }
//    }
//}

enum InAppReviewableJourneyType {
    case pllLoyaltyCard

    var identifier: String {
        switch self {
        case .pllLoyaltyCard:
            return "PLL Loyalty Card"
        }
    }
}

protocol InAppReviewableJourney {
    associatedtype T
    static var inProgressJourney: T? { get }
    var journeyType: InAppReviewableJourneyType { get }
    var isComplete: Bool { get }
    func begin()
    func end()
}

extension InAppReviewableJourney {
    static var inProgressJourney: T? {
        return Current.inAppReviewableJourney as? T
    }

    func begin() {
        // TODO: Check there isn't already a journey in progress
        Current.inAppReviewableJourney = self
    }

    func end() {
        Current.inAppReviewableJourney = nil
    }
}

struct PllLoyaltyInAppReviewableJourney: InAppReviewableJourney {
    typealias T = Self

    var journeyType: InAppReviewableJourneyType {
        return .pllLoyaltyCard
    }

    var isComplete: Bool {
        return hasAddedOrEnrolledPLLCard && hasLinkedPaymentCard && hasReturnedToLCD && hasReturnedToWalletFromLCD
    }

    var hasAddedOrEnrolledPLLCard = false
    var hasLinkedPaymentCard = false
    var hasReturnedToLCD = false
    var hasReturnedToWalletFromLCD = false
}
