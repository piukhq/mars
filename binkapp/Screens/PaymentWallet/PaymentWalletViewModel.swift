//
//  PaymentWalletViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import CardScan
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
//            let visionScanner = VNDocumentCameraViewController()
//            visionScanner.delegate = self
            
            let scannerViewController = ViewControllerFactory.makeScannerViewController(type: .payment, delegate: Current.navigate.scannerDelegate)
            
//            guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
            PermissionsUtility.launchPaymentScanner(scannerViewController) {
                let navigationRequest = ModalNavigationRequest(viewController: scannerViewController)
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
                if #available(iOS 14.0, *) {
                    BinkLogger.infoPrivateHash(event: PaymentCardLoggerEvent.paymentCardDeleted, value: card.id)
                }
                Current.wallet.refreshLocal()
            }
            }, onCancel: onCancel)
        
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}

extension PaymentWalletViewModel: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        VisionImageDetectionUtility().processImage(scan.imageOfPage(at: 0))
 
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //Handle properly error
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
}
