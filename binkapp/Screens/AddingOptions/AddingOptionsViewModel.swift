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

    func toLoyaltyScanner(delegate: BarcodeScannerViewControllerDelegate?) {
//        router.toLoyaltyScanner(delegate: delegate)
    }
    
    func toPaymentCardScanner(delegate: ScanDelegate?) {
//        router.toPaymentCardScanner(strings: strings, delegate: delegate)
    }

    func toAddAuth(membershipPlan: CD_MembershipPlan, barcode: String) {
//        let prefilledBarcodeValue = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
//        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, prefilledFormValues: [prefilledBarcodeValue])
    }
    
    func toBrowseBrandsScreen() {
//        router.toBrowseBrandsViewController()
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
//        router.toAddPaymentViewController(model: model)
    }

    @objc func close() {
        Current.navigate.close()
    }
}
