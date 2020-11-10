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
        viewModel.close()
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
    
    private func proceedWithCameraAccess(scanType: ScanType) {
        switch scanType {
        case .loyalty:
            viewModel.toLoyaltyScanner()
        case .payment:
            viewModel.toPaymentCardScanner()
        }
    }
}
