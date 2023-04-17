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
import BinkCore

enum MembershipCardsSortState: String {
    case newest = "Newest"
    case custom = "Custom"
    case recent = "Recent"
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
    
    func toBarcodeViewController(indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let card = cards?[indexPath.row] else {
            return
        }
        let viewController = ViewControllerFactory.makeBarcodeViewController(membershipCard: card)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, completion: completion)
        Current.navigate.to(navigationRequest)
        MixpanelUtility.track(.viewBarcode(brandName: card.membershipPlan?.account?.companyName ?? "Unknown", route: .wallet))
    }
    
    func toPoll() {
        let navigationRequest = PushNavigationRequest(viewController: ViewControllerFactory.makePollViewController())
        Current.navigate.to(navigationRequest)
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
                BinkLogger.infoPrivateHash(event: LoyaltyCardLoggerEvent.loyaltyCardDeleted, value: card.id)
                
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
    
    func getCurrentMembershipCardsSortType() -> MembershipCardsSortState? {
        if let type = Current.userDefaults.string(forDefaultsKey: .membershipCardsSortType) {
            if !type.isEmpty {
                return MembershipCardsSortState(rawValue: type)
            }
        }
        
        if let sortedCards = getLocalWalletOrderFromUserDefaults() {
            if !sortedCards.isEmpty {
                setMembershipCardsSortingType(sortType: .custom)
                return .custom
            }
        }
        
        setMembershipCardsSortingType(sortType: .newest)
        return .newest
    }
    
    func setMembershipCardsSortingType(sortType: MembershipCardsSortState?) {
        guard let value = sortType?.rawValue else { return }
        Current.userDefaults.set(value, forDefaultsKey: .membershipCardsSortType)
        MixpanelUtility.setUserProperty(.loyaltyCardsSortOrder(value))
    }
    
    func getLocalWalletOrderFromUserDefaults() -> [String]? {
        guard let userId = Current.userManager.currentUserId else { return nil }
        return Current.userDefaults.value(forDefaultsKey: .localWalletOrder(userId: userId, walletType: .loyalty)) as? [String]
    }
    
    func clearLocalWalletSortedCardsKey() {
        guard let userId = Current.userManager.currentUserId else { return }
        Current.userDefaults.set([String](), forDefaultsKey: .localWalletOrder(userId: userId, walletType: .loyalty))
    }
    
    func setMembershipCardMoved(hasMoved: Bool) {
        Current.userDefaults.set(hasMoved, forDefaultsKey: .hasMembershipOrderChanged)
    }
    
    func hasMembershipCardMoved() -> Bool {
        return Current.userDefaults.bool(forDefaultsKey: .hasMembershipOrderChanged)
    }
    
    func configureWhatsNewScreen() {
        guard let remoteConfigVersion = Current.remoteConfig.configFile?.whatsNew?.appVersion, let currentVersion = Bundle.currentVersion else { return }
        let hasDismissedWhatsNewModal = Current.userDefaults.bool(forDefaultsKey: .hasDismissedWhatsNewView)
        
        if remoteConfigVersion == currentVersion.versionString && !hasDismissedWhatsNewModal {
            presentWhatsNewView()
            Current.userDefaults.set(currentVersion.versionString, forDefaultsKey: .mostRecentAppVersion)
            return
        }
        
        if let mostRecentVersionString = Current.userDefaults.string(forDefaultsKey: .mostRecentAppVersion),
            let mostRecentAppVersion = AppVersion(versionString: mostRecentVersionString),
            let remoteConfigAppVersion = AppVersion(versionString: remoteConfigVersion) {
            if remoteConfigAppVersion.isMoreRecentThanVersion(mostRecentAppVersion) && currentVersion.versionString == remoteConfigVersion {
                presentWhatsNewView()
                Current.userDefaults.set(false, forDefaultsKey: .hasDismissedWhatsNewView)
                Current.userDefaults.set(currentVersion.versionString, forDefaultsKey: .mostRecentAppVersion)
            }
        }
    }
    
    private func presentWhatsNewView() {
        let viewModel = WhatsNewViewModel(features: Current.remoteConfig.configFile?.whatsNew?.features, merchants: Current.remoteConfig.configFile?.whatsNew?.merchants)
        let whatsNewViewController = ViewControllerFactory.makeWhatsNewViewController(viewModel: viewModel)
        let modalRequest = ModalNavigationRequest(viewController: whatsNewViewController, dragToDismiss: false, closeCompletion: {
            Current.userDefaults.set(true, forDefaultsKey: .hasDismissedWhatsNewView)
        })
        
        Current.navigate.to(modalRequest)
    }
}
