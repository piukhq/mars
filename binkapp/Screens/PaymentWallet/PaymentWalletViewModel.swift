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
    weak var paymentScanDelegate: ScanDelegate?
    private let paymentScanStrings = PaymentCardScannerStrings()

    var walletPrompts: [WalletPrompt]? {
        return WalletPromptFactory.makeWalletPrompts(forWallet: .payment, paymentScanDelegate: paymentScanDelegate)
    }

    var cards: [CD_PaymentCard]? {
        return Current.wallet.paymentCards
    }

    func toCardDetail(for card: CD_PaymentCard) {
//        router.toPaymentCardDetailViewController(paymentCard: card)
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
//        router.toAddPaymentViewController(model: model)
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .addPaymentCards(let scanDelegate):
            print(scanDelegate!)
//            router.toPaymentCardScanner(strings: paymentScanStrings, delegate: scanDelegate)
        default:
            return
        }
    }
    
    func showDeleteConfirmationAlert(card: CD_MembershipCard, onCancel: @escaping () -> Void) {
//        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
//            guard Current.apiClient.networkIsReachable else {
//                self?.router.presentNoConnectivityPopup()
//                noCompletion()
//                return
//            }
//            self?.repository.delete(card, completion: yesCompletion)
//            }, noCompletion: {
//                DispatchQueue.main.async {
//                    noCompletion()
//                }
//        })
    }
}
