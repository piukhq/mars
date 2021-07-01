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

    var walletPrompts: [WalletPrompt]?
    
    var cards: [CD_MembershipCard]? {
        return Current.wallet.membershipCards
    }
    
    func setupWalletPrompts() {
        walletPrompts = WalletPromptFactory.makeWalletPrompts(forWallet: .loyalty)
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
    
    func showDeleteConfirmationAlert(card: CD_MembershipCard, onCancel: @escaping () -> Void) {
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
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardDeleted, value: card.id)
                }
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
