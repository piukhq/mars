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

    private var accountsRefreshTimer: Timer!
    private var plansRefreshTimer: Timer!

    var canRefreshAccounts = true
    var canRefreshPlans = true
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
