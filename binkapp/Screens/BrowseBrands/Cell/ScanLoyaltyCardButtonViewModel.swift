//
//  ScanLoyaltyCardButtonViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 20/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import UIKit

class ScanLoyaltyCardButtonViewModel: NSObject {
    enum ScanButtonType {
        case retailer
        case custom
    }
    
    private let visionUtility = VisionUtility()
    var type: ScanButtonType
    
    init(type: ScanButtonType) {
        self.type = type
    }
    
    var title: String {
        switch type {
        case .retailer:
            return L10n.scanButtonTitle
        case .custom:
            return L10n.scanButtonCustomTitle
        }
    }
    
    var subtitle: String {
        switch type {
        case .retailer:
            return L10n.scanButtonSubtitle
        case .custom:
            return L10n.scanButtonCustomSubtitle
        }
    }

    func handleButtonTap() {
        let viewController = ViewControllerFactory.makeScannerViewController(type: .loyalty, hideNavigationBar: false, delegate: self)
        PermissionsUtility.launchLoyaltyScanner(viewController) {
            let navigationRequest = PushNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } addFromPhotoLibraryAction: {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            let navigationRequest = ModalNavigationRequest(viewController: picker, embedInNavigationController: false)
            Current.navigate.to(navigationRequest)
        }
    }
    
    private func showError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.loyaltyScannerFailedToDetectBarcode)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}

extension ScanLoyaltyCardButtonViewModel: BinkScannerViewControllerDelegate {
    func binkScannerViewController(_ viewController: BinkScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan?, completion: (() -> Void)?) {
        guard let membershipPlan = membershipPlan else { return }
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func binkScannerViewControllerShouldEnterManually(_ viewController: BinkScannerViewController, completion: (() -> Void)?) {
        switch type {
        case .retailer:
            Current.navigate.back()
        case .custom:
            if let customPlan = Current.wallet.membershipPlans?.first(where: { $0.isCustomCard }) {
                let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: customPlan, formPurpose: .add)
                let navigationRequest = PushNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        }
    }
}

extension ScanLoyaltyCardButtonViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        Current.navigate.close(animated: true) { [weak self] in
            guard let self = self else { return }
            self.visionUtility.detectBarcode(ciImage: image.ciImage(), completion: { barcode in
                guard let barcode = barcode else {
                    self.visionUtility.detectBarcodeString(from: image.ciImage(), completion: { barcode in
                        guard let barcode = barcode else {
                            DispatchQueue.main.async {
                                self.visionUtility.showError(barcodeDetected: false)
                            }
                            return
                        }
                        self.handleBarcodeDetection(barcode)
                    })
                    return
                }
                self.handleBarcodeDetection(barcode)
            })
        }
    }
    
    private func handleBarcodeDetection(_ barcode: String) {
        Current.wallet.identifyMembershipPlanForBarcode(barcode) { [weak self] plan in
            guard let plan = plan else {
                self?.visionUtility.showError(barcodeDetected: false)
                return
            }
            
            Current.navigate.close(animated: true) {
                let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
                let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: plan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
                let navigationRequest = PushNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
                HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
            }
        }
    }
}
