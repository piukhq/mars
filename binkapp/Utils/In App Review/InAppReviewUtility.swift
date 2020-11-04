//
//  InAppReviewUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 04/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

enum InAppReviewableJourneyError: BinkError {
    case journeyAlreadyInProgress(InAppReviewableJourney)

    var domain: BinkErrorDomain {
        return .inAppReviewableJourney
    }

    var message: String {
        switch self {
        case .journeyAlreadyInProgress(let journey):
            return "Journey already in progress: \(journey.journeyType.identifier)"
        }
    }
}

struct InAppReviewableJourney {
    enum JourneyType {
        case pllLoyaltyCard

        var identifier: String {
            switch self {
            case .pllLoyaltyCard:
                return "PLL Loyalty Card"
            }
        }
    }

    let journeyType: JourneyType
}

struct InAppReviewableJourneyManager {
    func start(_ journey: InAppReviewableJourney) throws {
        if let journeyInProgress = Current.inAppReviewableJourney {
            throw InAppReviewableJourneyError.journeyAlreadyInProgress(journeyInProgress)
        }
        Current.inAppReviewableJourney = journey
    }

    func end() {
        Current.inAppReviewableJourney = nil
    }
}
