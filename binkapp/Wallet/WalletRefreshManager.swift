//
//  WalletRefreshManager.swift
//  binkapp
//
//  Created by Nick Farrant on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class WalletRefreshManager {
    enum RefreshInterval: TimeInterval {
        case twoMinutes = 120
        case oneHour = 3600
        case twoHours = 7200
        case twelveHours = 43200
        case threeDays = 259200
        
        var readableValue: String {
            switch self {
            case .twoMinutes:
                return "two minutes"
            case .oneHour:
                return "one hour"
            case .twoHours:
                return "two hours"
            case .twelveHours:
                return "twelve hours"
            case .threeDays:
                return "three days"
            }
        }
    }
    
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
        accountsRefreshTimer = Timer.scheduledTimer(timeInterval: RefreshInterval.twoMinutes.rawValue, target: self, selector: #selector(handleAccountsRefreshTimerTrigger), userInfo: nil, repeats: false)
    }
    
    /// This should only be called on background launch
    func resetPlansTimer() {
        if plansRefreshTimer != nil {
            plansRefreshTimer.invalidate()
            canRefreshPlans = false
        }
        plansRefreshTimer = Timer.scheduledTimer(timeInterval: RefreshInterval.oneHour.rawValue, target: self, selector: #selector(handlePlansRefreshTimerTrigger), userInfo: nil, repeats: false)
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
            return elapsed >= Int(Current.pointsScrapingManager.isDebugMode ? RefreshInterval.twoMinutes.rawValue : RefreshInterval.twelveHours.rawValue)
        }
        return false
    }
    
    static func cardCanBeForceRefreshed(_ card: CD_MembershipCard) -> Bool {
        let balanceUpdated = Date(timeIntervalSince1970: getCardBalanceUpdatedTimestamp(card))
        let elapsed = Int(Date().timeIntervalSince(balanceUpdated))
        
        return elapsed >= Int(Current.pointsScrapingManager.isDebugMode ? RefreshInterval.twoMinutes.rawValue : RefreshInterval.twelveHours.rawValue)
    }
    
    static func cardCanRetainStaleBalance(_ card: CD_MembershipCard) -> Bool {
        let balanceUpdated = Date(timeIntervalSince1970: getCardBalanceUpdatedTimestamp(card))
        let elapsed = Int(Date().timeIntervalSince(balanceUpdated))
        
        return elapsed >= Int(Current.pointsScrapingManager.isDebugMode ? RefreshInterval.threeDays.rawValue : RefreshInterval.threeDays.rawValue)
    }
    
    private static func getCardBalanceUpdatedTimestamp(_ card: CD_MembershipCard) -> Double {
        guard let balance = card.formattedBalances?.first else {
            fatalError("We are performing a balance refresh but have no balance object.")
        }
        guard let updatedAt = balance.updatedAt?.doubleValue else {
            fatalError("Balance has no updatedAt value.")
        }
        return updatedAt
    }
}
