//
//  WalletRefreshManager.swift
//  binkapp
//
//  Created by Nick Farrant on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class WalletRefreshManager {
    private static let oneHour: TimeInterval = 3600
    private static let twoMinutes: TimeInterval = 120
    private static let twoHours: TimeInterval = 7200

    private var accountsRefreshTimer: Timer!
    private var plansRefreshTimer: Timer!

    var canRefreshAccounts = false
    var canRefreshPlans = false
    var isActive = false

    func start() {
        resetAll()
        isActive = true
        print(Current.pointsScrapingManager.refreshableMembershipCardIds())
    }

    /// This should only be called after a pull to refresh
    func resetAll() {
        resetAccountsTimer()
        resetPlansTimer()
    }

    /// This should only be called on wallet appear
    func resetAccountsTimer() {
        if accountsRefreshTimer != nil {
            accountsRefreshTimer.invalidate()
            canRefreshAccounts = false
        }
        accountsRefreshTimer = Timer.scheduledTimer(timeInterval: WalletRefreshManager.twoMinutes, target: self, selector: #selector(handleAccountsRefreshTimerTrigger), userInfo: nil, repeats: false)
    }

    /// This should only be called on background launch
    func resetPlansTimer() {
        if plansRefreshTimer != nil {
            plansRefreshTimer.invalidate()
            canRefreshPlans = false
        }
        plansRefreshTimer = Timer.scheduledTimer(timeInterval: WalletRefreshManager.oneHour, target: self, selector: #selector(handlePlansRefreshTimerTrigger), userInfo: nil, repeats: false)
    }

    @objc private func handleAccountsRefreshTimerTrigger() {
        canRefreshAccounts = true
    }

    @objc private func handlePlansRefreshTimerTrigger() {
        canRefreshPlans = true
    }
}

// MARK: - Local Points Scraping

extension WalletRefreshManager {
    static func canRefreshScrapedValueForMembershipCard(_ card: CD_MembershipCard) -> Bool {
        if let balanceLastUpdatedTimeStamp = card.formattedBalances?.first?.updatedAt?.doubleValue {
            let balanceLastUpdatedDate = Date(timeIntervalSince1970: balanceLastUpdatedTimeStamp)
            // Cast to Int to get number of seconds
            let elapsed = Int(Date().timeIntervalSince(balanceLastUpdatedDate))
            return elapsed >= Int(WalletRefreshManager.twoHours)
        }
        return false
    }
}
