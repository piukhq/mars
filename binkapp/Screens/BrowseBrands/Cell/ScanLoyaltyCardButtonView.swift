//
//  ScanLoyaltyCardButtonView.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI
import Lottie

struct ScanLoyaltyCardButtonView: View {
    var viewModel = ScanLoyaltyCardButtonViewModel()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                .fill(LinearGradient(gradient: Gradient(colors: [Color(.binkGradientBlueRight), Color(.binkGradientBlueLeft)]), startPoint: .leading, endPoint: .trailing))
            HStack(spacing: 15) {
                Image(uiImage: Asset.scanQuick.image)
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text(L10n.scanButtonTitle)
                        .font(.nunitoExtraBold(20))
                        .foregroundColor(.white)
                    Text(L10n.scanButtonSubtitle)
                        .font(.nunitoSans(15))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: 1800, maxHeight: 88)
        .onTapGesture {
            viewModel.handleButtonTap()
        }
    }
}

class ScanLoyaltyCardButtonViewModel: NSObject, BarcodeScannerViewControllerDelegate {
    private let visionUtility = VisionImageDetectionUtility()

    func handleButtonTap() {
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(hideNavigationBar: false, delegate: self)
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
    
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        Current.navigate.back()
    }
    
    private func showError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.loyaltyScannerFailedToDetectBarcode)
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
}

extension ScanLoyaltyCardButtonViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        visionUtility.createVisionRequest(image: image) { [weak self] barcode in
            guard let barcode = barcode else {
                Current.navigate.close(animated: true) { [weak self] in
                    self?.showError()
                }
                return
            }

            Current.wallet.identifyMembershipPlanForBarcode(barcode) { membershipPlan in
                guard let membershipPlan = membershipPlan else {
                    self?.showError()
                    return
                }
                Current.navigate.close(animated: true) {
                    let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
                    let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
                    let navigationRequest = PushNavigationRequest(viewController: viewController)
                    Current.navigate.to(navigationRequest)
                    HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
                }
            }
        }
    }
}


struct ScanLoyaltyCardButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ScanLoyaltyCardButtonView()
    }
}
