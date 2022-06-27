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

enum MembershipCardsSortState {
    case newest
    case custom
    
    var keyValue: String {
        switch self {
        case .newest:
            return "Newest"
        case .custom:
            return "Custom"
        }
    }
}

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
    
    func getCurrentMembershipCardsSortType() -> String {
        if let type = Current.userDefaults.string(forDefaultsKey: .membershipCardsSortType) {
            if !type.isEmpty {
                return type
            }
        }
        
        let newestString = MembershipCardsSortState.newest.keyValue
        let customString = MembershipCardsSortState.custom.keyValue
        
        if let sortedCards = localWalletSortedCardsKey() {
            if !sortedCards.isEmpty {
                setMembershipCardsSortingType(sortType: customString)
                return customString
            }
        }
        
        setMembershipCardsSortingType(sortType: newestString)
        return newestString
    }
    
    func setMembershipCardsSortingType(sortType: String) {
        Current.userDefaults.set(sortType, forDefaultsKey: .membershipCardsSortType)
        MixpanelUtility.track(.membershipCardsSortOrder(value: sortType))
    }
    
    func localWalletSortedCardsKey() -> [String]? {
        guard let userId = Current.userManager.currentUserId else {
            return nil
        }
        return Current.userDefaults.value(forDefaultsKey: UserDefaults.Keys.localWalletOrder(userId: userId, walletType: Wallet.WalletType.loyalty)) as? [String]
    }
    
    func clearLocalWalletSortedCardsKey() {
        guard let userId = Current.userManager.currentUserId else {
            return
        }
        
        Current.userDefaults.set([String](), forDefaultsKey: UserDefaults.Keys.localWalletOrder(userId: userId, walletType: Wallet.WalletType.loyalty))
    }
    
    func setMembershipCardMoved(hasMoved: Bool) {
        Current.userDefaults.set(hasMoved, forDefaultsKey: .hasMembershipOrderChanged)
    }
    
    func hasMembershipCardMoved() -> Bool {
        return Current.userDefaults.bool(forDefaultsKey: .hasMembershipOrderChanged)
    }
    
    func toBarcodeViewController(indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let card = cards?[indexPath.row] else {
            return
        }
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: card)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, completion: completion)
        Current.navigate.to(navigationRequest)
        MixpanelUtility.track(.viewBarcode(brandName: card.membershipPlan?.account?.companyName ?? "Unknown", route: .wallet))
    }
    
    func toCardDetail(for card: CD_MembershipCard) {
        let navigationRequest = PushNavigationRequest(viewController: ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: card))
        Current.navigate.to(navigationRequest)
        MixpanelUtility.track(.lcdViewed(brandName: card.membershipPlan?.account?.companyName ?? "Unknown", route: .wallet))
    }
    
    func showSortOrderChangeAlert(onCancel: @escaping () -> Void) {
        let alert = ViewControllerFactory.makeOkCancelAlertViewController(title: L10n.alertViewChangingSort, message: L10n.alertViewChangingSortBody, cancelButton: true) {
            onCancel()
        }
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
        
    func showDeleteConfirmationAlert(card: CD_MembershipCard, onCancel: @escaping () -> Void) {
        guard card.status?.status != .pending else {
            let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.alertViewCannotDeleteCardTitle, message: L10n.alertViewCannotDeleteCardBody) {
                onCancel()
            }
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
            return
        }
        
        let alert = ViewControllerFactory.makeDeleteConfirmationAlertController(message: L10n.deleteCardConfirmation, deleteAction: { [weak self] in
            guard let self = self else { return }
            guard Current.apiClient.networkIsReachable else {
                let alert = ViewControllerFactory.makeNoConnectivityAlertController()
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
                onCancel()
                return
            }
            
            Current.watchController.deleteLoyaltyCardFromWatch(barcode: card.card?.barcode ?? "")
            let brandName = card.membershipPlan?.account?.companyName
            self.repository.delete(card) {
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardDeleted, value: card.id)
                }
                
                MixpanelUtility.track(.loyaltyCardDeleted(brandName: brandName ?? "Unknown", route: .wallet))
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
