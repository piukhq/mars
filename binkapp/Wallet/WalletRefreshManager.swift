//
//  WalletRefreshManager.swift
//  binkapp
//
//  Created by Nick Farrant on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class WalletRefreshManager {
    private static let twoMinutes: TimeInterval = 120
    private static let oneHour: TimeInterval = 3600
    private static let twoHours: TimeInterval = oneHour * 2
    private static let twelveHours: TimeInterval = oneHour * 12
    private static let threeDays: TimeInterval = oneHour * 72

    private var accountsRefreshTimer: Timer!
    private var plansRefreshTimer: Timer!

    var canRefreshAccounts = false
    var canRefreshPlans = false
    var isActive = false

    func start() {
        resetAll()
        isActive = true
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
            let elapsed = Int(Date().timeIntervalSince(balanceLastUpdatedDate))
            return elapsed >= Int(Current.pointsScrapingManager.isDebugMode ? WalletRefreshManager.twoMinutes : WalletRefreshManager.twelveHours)
        }
        return false
    }
    
    static func cardCanRetainStaleBalance(_ card: CD_MembershipCard) -> Bool {
        guard let balance = card.formattedBalances?.first else {
            fatalError("We are performing a balance refresh but have no balance object.")
        }
        guard let updatedAt = balance.updatedAt?.doubleValue else {
            fatalError("Balance has no updatedAt value.")
        }
        
        let balanceUpdated = Date(timeIntervalSince1970: updatedAt)
        let elapsed = Int(Date().timeIntervalSince(balanceUpdated))
        
        return elapsed >= Int(Current.pointsScrapingManager.isDebugMode ? WalletRefreshManager.threeDays : WalletRefreshManager.threeDays)
    }
}
