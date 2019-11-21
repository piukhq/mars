//
//  WalletRefreshManager.swift
//  binkapp
//
//  Created by Nick Farrant on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class WalletRefreshManager {
    private static let oneMinute: TimeInterval = 5
    private static let twoMinutes: TimeInterval = 10

    private var accountsRefreshTimer: Timer!
    private var plansRefreshTimer: Timer!

    var canRefreshAccounts = true
    var canRefreshPlans = true
    var isActive = false

    func start() {
        canRefreshAccounts = false
        canRefreshPlans = false
        accountsRefreshTimer = Timer.scheduledTimer(timeInterval: WalletRefreshManager.twoMinutes, target: self, selector: #selector(handleAccountsRefreshTimerTrigger), userInfo: nil, repeats: false)
        plansRefreshTimer = Timer.scheduledTimer(timeInterval: WalletRefreshManager.oneMinute, target: self, selector: #selector(handlePlansRefreshTimerTrigger), userInfo: nil, repeats: false)
        isActive = true
    }

    func reset() {
        accountsRefreshTimer.invalidate()
        plansRefreshTimer.invalidate()
        start()
    }

    @objc private func handleAccountsRefreshTimerTrigger() {
        canRefreshAccounts = true
    }

    @objc private func handlePlansRefreshTimerTrigger() {
        canRefreshPlans = true
    }
}
