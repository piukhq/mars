//
//  ScanLoyaltyCardButton.swift
//  binkapp
//
//  Created by Sean Williams on 10/05/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

protocol ScanLoyaltyCardButtonDelegate: AnyObject {
    func addPhotoFromLibraryButtonWasTapped(_ scanLoyaltyCardButton: ScanLoyaltyCardButton)
}

class ScanLoyaltyCardButton: UIView {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var gradientView: UIView!
    
    private let cornerRadius: CGFloat = 10.0
    weak var delegate: ScanLoyaltyCardButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = L10n.scanButtonTitle
        subtitleLabel.text = L10n.scanUttonSubtitle
        iconImageView.image = Asset.scanQuick.image
        CAGradientLayer.makeGradient(for: gradientView, firstColor: .binkGradientBlueRight, secondColor: .binkGradientBlueLeft, startPoint: CGPoint(x: 1.0, y: 0.0))

        layer.cornerRadius = cornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = false
        layer.applyDefaultBinkShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        gradientView.layer.cornerRadius = cornerRadius
        gradientView.layer.cornerCurve = .continuous
        gradientView.clipsToBounds = true
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(hideNavigationBar: false, delegate: self)
        PermissionsUtility.launchLoyaltyScanner(viewController) {
            let navigationRequest = PushNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        } addFromPhotoLibraryAction: { [weak self] in
            guard let self = self else { return }
            self.delegate?.addPhotoFromLibraryButtonWasTapped(self)
        }
    }
}

extension ScanLoyaltyCardButton: BarcodeScannerViewControllerDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        Current.navigate.back()
    }
}
