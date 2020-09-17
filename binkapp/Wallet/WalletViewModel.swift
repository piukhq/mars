//
//  WalletViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

protocol WalletViewModel {
    associatedtype T
    
    var cards: [T]? { get }
    var cardCount: Int { get }
    var walletPromptsCount: Int { get }
    var walletPrompts: [WalletPrompt]? { get }
    func promptCard(forIndexPath indexPath: IndexPath) -> WalletPrompt?
    func reloadWallet()
    func refreshLocalWallet()
    func toCardDetail(for card: T)
    func toSettings(rowsWithActionRequired: [SettingsRow.RowType]?)
    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt)
    func showDeleteConfirmationAlert(card: T, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void)
    func toAddPaymentCardScreen(model: PaymentCardCreateModel?)
}

extension WalletViewModel {
    var walletPromptsCount: Int {
        return walletPrompts?.count ?? 0
    }

    var cardCount: Int {
        return cards?.count ?? 0
    }

    func promptCard(forIndexPath indexPath: IndexPath) -> WalletPrompt? {
        return walletPrompts?[safe: indexPath.row - cardCount]
    }

    func reloadWallet() {
        Current.wallet.reload()
    }

    func refreshLocalWallet() {
        Current.wallet.refreshLocal()
    }
    
    func toSettings(rowsWithActionRequired: [SettingsRow.RowType]?) {
        let viewModel = SettingsViewModel(rowsWithActionRequired: rowsWithActionRequired)
        let viewController = SettingsViewController(viewModel: viewModel)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, fullScreen: true)
        Current.navigate.to(navigationRequest)
    }
}
