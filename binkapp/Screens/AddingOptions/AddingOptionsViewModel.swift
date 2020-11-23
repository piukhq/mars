//
//  AddingOptionsViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 06/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class AddingOptionsViewModel {
    func toLoyaltyScanner() {
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(delegate: Current.navigate.loyaltyCardScannerDelegate)
        PermissionsUtility.launchLoyaltyScanner(viewController, grantedAction: {
            Current.navigate.close {
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }, enterManuallyAction: { [weak self] in
            self?.toBrowseBrandsScreen()
        })
    }
    
    func toPaymentCardScanner() {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: Current.paymentCardScannerStrings, delegate: Current.navigate.paymentCardScannerDelegate) else { return }
        PermissionsUtility.launchPaymentScanner(viewController, grantedAction: {
            Current.navigate.close {
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }, enterManuallyAction: { [weak self] in
            self?.toAddPaymentCardScreen()
        })
    }
    
    func toBrowseBrandsScreen() {
        Current.navigate.close {
            let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        Current.navigate.close {
            let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model, journey: .wallet)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
        
    }

    @objc func close() {
        Current.navigate.close()
    }
}
