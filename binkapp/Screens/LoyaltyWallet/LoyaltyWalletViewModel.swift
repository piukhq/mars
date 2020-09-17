//
//  LoyaltyWalletViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff
import CoreData
import CardScan

class LoyaltyWalletViewModel: WalletViewModel {
    
    typealias T = CD_MembershipCard

    private let repository = LoyaltyWalletRepository()
    weak var paymentScanDelegate: ScanDelegate?
    private let paymentScanStrings = PaymentCardScannerStrings()

    var walletPrompts: [WalletPrompt]? {
        return WalletPromptFactory.makeWalletPrompts(forWallet: .loyalty, paymentScanDelegate: paymentScanDelegate)
    }
    
    var cards: [CD_MembershipCard]? {
         return Current.wallet.membershipCards
     }

    func toBarcodeViewController(indexPath: IndexPath, completion: @escaping () -> ()) {
        guard let card = cards?[indexPath.row] else {
            return
        }
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: card)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, completion: completion)
        Current.navigate.to(navigationRequest)
    }

    func toCardDetail(for card: CD_MembershipCard) {
        let navigationRequest = PushNavigationRequest(viewController: ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: card))
        Current.navigate.to(navigationRequest)
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .loyaltyJoin(let membershipPlan):
            print(membershipPlan)
//            router.toAddOrJoinViewController(membershipPlan: membershipPlan)
        case .addPaymentCards(let scanDelegate):
            print(scanDelegate!)
//            router.toPaymentCardScanner(strings: paymentScanStrings, delegate: scanDelegate)
        }
    }

    func showDeleteConfirmationAlert(card: CD_MembershipCard, onCancel: @escaping () -> Void) {
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
    
    func showNoBarcodeAlert(completion: @escaping () -> Void) {
//        router.showNoBarcodeAlert {
//            DispatchQueue.main.async {
//                completion()
//            }
//        }
    }
}
