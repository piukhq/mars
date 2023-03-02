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

struct TransactionsHistoryInAppReviewableJourney: InAppReviewableJourney {
    typealias J = Self
}

struct TimeAndUsageBasedInAppReviewableJourney: InAppReviewableJourney {
    typealias J = Self
}

enum InAppReviewUtility {
    static let minimumMembershipCards = 3
    static let minimumAppLaunches = 5
    static let minimumDaysSinceFirstLaunch = 2
    static let minimumForegroundRefreshes = 1

    static func recordAppLaunch() {
        let timestamp = Date().timeIntervalSince1970
        var appLaunches = Current.userDefaults.value(forDefaultsKey: .appLaunches) as? [TimeInterval]
        appLaunches?.append(timestamp)
        Current.userDefaults.set(appLaunches ?? [timestamp], forDefaultsKey: .appLaunches)
    }
    
    static var canRequestReviewBasedOnUsage: Bool {
        guard let membershipCards = Current.wallet.membershipCards, membershipCards.count > minimumMembershipCards else { return false }
        guard let appLaunches = Current.userDefaults.value(forDefaultsKey: .appLaunches) as? [TimeInterval] else { return false }
        guard appLaunches.count > minimumAppLaunches else { return false }
        guard Current.wallet.foregroundRefreshCount >= minimumForegroundRefreshes else { return false }
        let firstAppLaunch = Date(timeIntervalSince1970: appLaunches[0])
        return Date.hasElapsed(days: minimumDaysSinceFirstLaunch, since: firstAppLaunch)
    }
}
