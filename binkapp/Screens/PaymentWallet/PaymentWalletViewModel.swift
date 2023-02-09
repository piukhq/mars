//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import VisionKit

class PaymentWalletViewModel: NSObject, WalletViewModel {
    typealias T = CD_PaymentCard

    private let repository = PaymentWalletRepository()

    var walletPrompts: [WalletPrompt]?

    var cards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }
    
    func setupWalletPrompts() {
        walletPrompts = WalletPromptFactory.makeWalletPrompts(forWallet: .payment)
    }

    func toCardDetail(for card: CD_PaymentCard) {
        let viewController = ViewControllerFactory.makePaymentCardDetailViewController(paymentCard: card)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .addPaymentCards:
            let viewController = ViewControllerFactory.makeScannerViewController(type: .payment, delegate: Current.navigate.scannerDelegate)
            PermissionsUtility.launchLoyaltyScanner(viewController) {
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            } enterManuallyAction: {
                let addPaymentCardViewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
                let navigationRequest = ModalNavigationRequest(viewController: addPaymentCardViewController)
                Current.navigate.to(navigationRequest)
            }
        default:
            return
        }
    }
    
    func showDeleteConfirmationAlert(card: CD_PaymentCard, onCancel: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: L10n.deleteCardConfirmation, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                onCancel()
                return
            }
            self.repository.delete(card) {
                BinkLogger.infoPrivateHash(event: PaymentCardLoggerEvent.paymentCardDeleted, value: card.id)
                Current.wallet.refreshLocal()
            }
            }, onCancel: onCancel)
        
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}
