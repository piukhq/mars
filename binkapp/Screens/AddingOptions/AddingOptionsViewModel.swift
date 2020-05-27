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
    private let strings = PaymentCardScannerStrings()
    
    private let router: MainScreenRouter
    init(router: MainScreenRouter) {
        self.router = router
    }

    func toLoyaltyScanner(delegate: BarcodeScannerViewControllerDelegate?) {
        router.toLoyaltyScanner(delegate: delegate)
    }
    
    func toPaymentCardScanner(delegate: ScanDelegate?) {
        router.toPaymentCardScanner(strings: strings, delegate: delegate)
    }

    func toAddAuth(membershipPlan: CD_MembershipPlan, barcode: String) {
        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner(barcode: barcode))
    }
    
    func toBrowseBrandsScreen() {
        router.toBrowseBrandsViewController()
    }
    
    func toAddPaymentCardScreen() {
        router.toAddPaymentViewController()
    }

    @objc func popViewController() {
        router.popViewController()
    }
}
