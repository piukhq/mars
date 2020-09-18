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
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(delegate: delegate)
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toBrowseBrandsScreen()
        }

        if PermissionsUtility.videoCaptureIsAuthorized {
            Current.navigate.close {
                let navigationRequest = ModalNavigationRequest(viewController: viewController, embedInNavigationController: false)
                Current.navigate.to(navigationRequest)
            }
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    Current.navigate.close {
                        let navigationRequest = ModalNavigationRequest(viewController: viewController, embedInNavigationController: false)
                        Current.navigate.to(navigationRequest)
                    }
                } else {
                    if let alert = enterManuallyAlert {
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    }
                }
            }
        }
    }
    
    func toPaymentCardScanner(delegate: ScanDelegate?) {
        guard let viewController = ViewControllerFactory.makePaymentCardScannerViewController(strings: strings, delegate: delegate) else { return }
        
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            self?.toAddPaymentCardScreen()
        }
        
        if PermissionsUtility.videoCaptureIsAuthorized {
            Current.navigate.close {
                let navigationRequest = ModalNavigationRequest(viewController: viewController, embedInNavigationController: false)
                Current.navigate.to(navigationRequest)
            }
        } else if PermissionsUtility.videoCaptureIsDenied {
            if let alert = enterManuallyAlert {
                let navigationRequest = AlertNavigationRequest(alertController: alert)
                Current.navigate.to(navigationRequest)
            }
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    Current.navigate.close {
                        let navigationRequest = ModalNavigationRequest(viewController: viewController, embedInNavigationController: false)
                        Current.navigate.to(navigationRequest)
                    }
                } else {
                    if let alert = enterManuallyAlert {
                        let navigationRequest = AlertNavigationRequest(alertController: alert)
                        Current.navigate.to(navigationRequest)
                    }
                }
            }
        }
    }

    func toAddAuth(membershipPlan: CD_MembershipPlan, barcode: String) {
//        let prefilledBarcodeValue = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
//        router.toAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, prefilledFormValues: [prefilledBarcodeValue])
    }
    
    func toBrowseBrandsScreen() {
        Current.navigate.close {
            let viewController = ViewControllerFactory.makeBrowseBrandsViewController()
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    func toAddPaymentCardScreen(model: PaymentCardCreateModel? = nil) {
        let viewController = ViewControllerFactory.makeAddPaymentCardViewController(model: model)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }

    @objc func close() {
        Current.navigate.close()
    }
}
