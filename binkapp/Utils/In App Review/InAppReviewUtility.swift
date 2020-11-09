//
//  InAppReviewUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 04/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

protocol InAppReviewableJourney {
    associatedtype J

    static var isInProgress: Bool { get }
    func begin()
    static func end()
}

extension InAppReviewableJourney {
    static var isInProgress: Bool {
        if let _ = Current.inAppReviewableJourney as? J {
            return true
        }
        return false
    }

    func begin() {
        guard Current.inAppReviewableJourney == nil else { return }
        Current.inAppReviewableJourney = self
    }

    static func end() {
        if isInProgress {
            Current.inAppReviewableJourney = nil
        }
    }
}

struct PllLoyaltyInAppReviewableJourney: InAppReviewableJourney {
    typealias J = Self
}
