//
//  WalletViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol WalletViewModel {
    associatedtype T
    associatedtype R

    init(repository: R, router: MainScreenRouter)
    var cards: [T]? { get }
    var cardCount: Int { get }
    var joinCardCount: Int { get }
    var joinCards: [JoinCard]? { get }
    func card(forIndexPath indexPath: IndexPath) -> T?
    func reloadWallet()
    func refreshLocalWallet()
    func toCardDetail(for card: T)
}

extension WalletViewModel {
    var joinCardCount: Int {
        return joinCards?.count ?? 0
    }

    var cardCount: Int {
        return cards?.count ?? 0
    }

    func card(forIndexPath indexPath: IndexPath) -> T? {
        return cards?[indexPath.row - joinCardCount]
    }

    func reloadWallet() {
        Current.wallet.reload()
    }

    func refreshLocalWallet() {
        Current.wallet.refreshLocal()
    }
}
