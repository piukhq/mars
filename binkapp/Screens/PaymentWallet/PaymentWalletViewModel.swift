//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan

class PaymentWalletViewModel: WalletViewModel {
    typealias T = CD_PaymentCard

    private let repository = PaymentWalletRepository()

    var walletPrompts: [WalletPrompt]? {
        return WalletPromptFactory.makeWalletPrompts(forWallet: .payment)
    }

    var cards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }

    func toCardDetail(for card: CD_PaymentCard) {
        let viewController = ViewControllerFactory.makePaymentCardDetailViewController(paymentCard: card)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .addPaymentCards:
            guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        default:
            return
        }
    }
    
    func showDeleteConfirmationAlert(card: CD_PaymentCard, onCancel: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: "delete_card_confirmation".localized, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                onCancel()
                return
            }
            self.repository.delete(card) {
                Current.wallet.refreshLocal()
            }
            }, onCancel: onCancel)
        
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
