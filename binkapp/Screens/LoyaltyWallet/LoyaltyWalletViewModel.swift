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

    var walletPrompts: [WalletPrompt]? {
        print("wallet prompts called")
        return WalletPromptFactory.makeWalletPrompts(forWallet: .loyalty)
    }
    
    var cards: [CD_MembershipCard]? {
        return Current.wallet.membershipCards
    }
    
    func toBarcodeViewController(indexPath: IndexPath, completion: @escaping () -> Void) {
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
    
    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
//        case .loyaltyJoin(let membershipPlan):
//            let viewController = ViewControllerFactory.makeAddOrJoinViewController(membershipPlan: membershipPlan)
//            let navigationRequest = ModalNavigationRequest(viewController: viewController)
//            Current.navigate.to(navigationRequest)
        case .addPaymentCards:
            guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
            PermissionsUtility.launchPaymentScanner(viewController) {
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            } enterManuallyAction: {
                let addPaymentCardViewController = ViewControllerFactory.makeAddPaymentCardViewController(journey: .wallet)
                let navigationRequest = ModalNavigationRequest(viewController: addPaymentCardViewController)
                Current.navigate.to(navigationRequest)
            }
        case .link:
            print("Cell tapped")
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
        let alert = ViewControllerFactory.makeOkAlertViewController(title: "No Barcode", message: "No barcode or card number to display. Please check the status of this card.")
        let navigationRequest = AlertNavigationRequest(alertController: alert, completion: completion)
        Current.navigate.to(navigationRequest)
    }
}
