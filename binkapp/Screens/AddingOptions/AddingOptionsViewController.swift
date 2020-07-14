//
//  AddingOptionsViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 02/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import CardScan

class AddingOptionsViewController: BinkTrackableViewController {
    enum ScanType {
        case loyalty
        case payment
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var stackviewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackviewTopConstraint: NSLayoutConstraint!
    
    let viewModel: AddingOptionsViewModel
    let loyaltyCardView = AddingOptionView()
    let browseBrandsView = AddingOptionView()
    let addPaymentCardView = AddingOptionView()
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        viewModel.popViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .addOptions)
    }
    
    init(viewModel: AddingOptionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddingOptionsViewController", bundle: Bundle(for: AddingOptionsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureUI() {
        self.title = ""
        let maximumHeight: CGFloat = 185
        loyaltyCardView.configure(addingOption: .loyalty)
        browseBrandsView.configure(addingOption: .browse)
        addPaymentCardView.configure(addingOption: .payment)

        NSLayoutConstraint.activate([
                      loyaltyCardView.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight),
                      browseBrandsView.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight),
                      addPaymentCardView.heightAnchor.constraint(lessThanOrEqualToConstant: maximumHeight)
        ])
        
        addGesturesToViews()
        stackView.addArrangedSubview(loyaltyCardView)
        stackView.addArrangedSubview(browseBrandsView)
        stackView.addArrangedSubview(addPaymentCardView)

        stackView.layoutIfNeeded()
        let constant = addPaymentCardView.frame.height * 0.75
        stackviewBottomConstraint.priority = .defaultLow
        stackviewBottomConstraint.constant = constant
    }
    
    func addGesturesToViews() {
        loyaltyCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toAddLoyaltyCard)))
        browseBrandsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toBrowseBrands)))
        addPaymentCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.toAddPaymentCard)))
    }
    
    @objc func toAddLoyaltyCard() {
        proceedWithCameraAccess(scanType: .loyalty)
    }
    
    @objc func toBrowseBrands() {
        viewModel.toBrowseBrandsScreen()
    }
    
    @objc func toAddPaymentCard() {
        proceedWithCameraAccess(scanType: .payment)
    }
    
    func displayNoScreenPopup() {
        let alert = UIAlertController(title: nil, message: "Screen was not implemented yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func proceedWithCameraAccess(scanType: ScanType) {
        if PermissionsUtility.videoCaptureIsAuthorized {
            switch scanType {
            case .loyalty:
                viewModel.toLoyaltyScanner(delegate: self)
            case .payment:
                viewModel.toPaymentCardScanner(delegate: self)
            }
        } else if PermissionsUtility.videoCaptureIsDenied {
            presentEnterManuallyAlert(scanType: scanType)
        } else {
            PermissionsUtility.requestVideoCaptureAuthorization { granted in
                if granted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        guard let self = self else { return }
                        switch scanType {
                        case .loyalty:
                            self.viewModel.toLoyaltyScanner(delegate: self)
                        case .payment:
                            self.viewModel.toPaymentCardScanner(delegate: self)
                        }
                    })
                } else {
                    self.presentEnterManuallyAlert(scanType: scanType)
                }
            }
        }
    }
    
    private func presentEnterManuallyAlert(scanType: ScanType) {
        let enterManuallyAlert = UIAlertController.cardScannerEnterManuallyAlertController { [weak self] in
            switch scanType {
            case .loyalty:
                self?.toBrowseBrands()
            case .payment:
                self?.viewModel.toAddPaymentCardScreen()
            }
        }
        guard let alert = enterManuallyAlert else { return }
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddingOptionsViewController: BarcodeScannerViewControllerDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        viewModel.toAddAuth(membershipPlan: membershipPlan, barcode: barcode)
        completion?()
    }

    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        viewModel.toBrowseBrandsScreen()
        completion?()
    }
}

extension AddingOptionsViewController: ScanDelegate {
    func userDidCancel(_ scanViewController: ScanViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        // Record Bouncer usage
        BinkAnalytics.track(.paymentScan(success: true))
        let month = Int(creditCard.expiryMonth ?? "")
        let year = Int(creditCard.expiryYear ?? "")
        let model = PaymentCardCreateModel(fullPan: creditCard.number, nameOnCard: nil, month: month, year: year)
        viewModel.toAddPaymentCardScreen(model: model)
        navigationController?.removeViewController(scanViewController)
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        viewModel.toAddPaymentCardScreen()
        navigationController?.removeViewController(scanViewController)
    }
}

class PaymentCardScannerStrings: ScanStringsDataSource {
    func scanCard() -> String {
        return " "
    }
    
    func positionCard() -> String {
        return "Position your payment card in the area above"
    }
    
    func backButton() -> String {
        return " "
    }
    
    func skipButton() -> String {
        "Enter manually"
    }
}
