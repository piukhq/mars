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
    private let router: MainScreenRouter
    weak var paymentScanDelegate: ScanDelegate?
    private let paymentScanStrings = PaymentCardScannerStrings()
    
    required init(router: MainScreenRouter) {
        self.router = router
    }

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
        
        router.toBarcodeViewController(membershipCard: card, completion: completion)
    }

    func toCardDetail(for card: CD_MembershipCard) {
//        router.toLoyaltyFullDetailsScreen(membershipCard: card)
        let repository = LoyaltyCardFullDetailsRepository(apiClient: APIClient())
        let factory = PaymentCardDetailInformationRowFactory()
        let viewModel = LoyaltyCardFullDetailsViewModel(membershipCard: card, repository: repository, router: MainScreenRouter(delegate: nil), informationRowFactory: factory)
        let viewController = LoyaltyCardFullDetailsViewController(viewModel: viewModel)
        factory.delegate = viewController
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        router.toAddPaymentViewController(model: model)
    }

    func didSelectWalletPrompt(_ walletPrompt: WalletPrompt) {
        switch walletPrompt.type {
        case .loyaltyJoin(let membershipPlan):
            router.toAddOrJoinViewController(membershipPlan: membershipPlan)
        case .addPaymentCards(let scanDelegate):
            router.toPaymentCardScanner(strings: paymentScanStrings, delegate: scanDelegate)
        }
    }

    func showDeleteConfirmationAlert(card: CD_MembershipCard, yesCompletion: @escaping () -> Void, noCompletion: @escaping () -> Void) {
        router.showDeleteConfirmationAlert(withMessage: "delete_card_confirmation".localized, yesCompletion: { [weak self] in
            guard Current.apiClient.networkIsReachable else {
                self?.router.presentNoConnectivityPopup()
                noCompletion()
                return
            }
            self?.repository.delete(card, completion: yesCompletion)
        }, noCompletion: {
            DispatchQueue.main.async {
                noCompletion()
            }
        })
    }
    
    func showNoBarcodeAlert(completion: @escaping () -> Void) {
        router.showNoBarcodeAlert {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func toSettings(rowsWithActionRequired: [SettingsRow.RowType]?) {
//        router.toSettings(rowsWithActionRequired: rowsWithActionRequired)
        let viewModel = SettingsViewModel(router: MainScreenRouter(delegate: nil), rowsWithActionRequired: rowsWithActionRequired)
        let viewController = SettingsViewController(viewModel: viewModel)
        let navigationRequest = ModalNavigationRequest(viewController: viewController, fullScreen: true)
        Current.navigate.to(navigationRequest)
    }
}
