//
//  AddingOptionsViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 02/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class AddingOptionsViewController: BinkTrackableViewController {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        proceedWithCameraAccess()
    }
    
    @objc func toBrowseBrands() {
        viewModel.toBrowseBrandsScreen()
    }
    
    @objc func toAddPaymentCard() {
        viewModel.toAddPaymentCardScreen()
    }
    
    func displayNoScreenPopup() {
        let alert = UIAlertController(title: nil, message: "Screen was not implemented yet", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func proceedWithCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            viewModel.toLoyaltyScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    //Added a delay because was the quickest way to make sure the no screen popup will be dispplayed and didn't want to spend anymore time on this as it will be removed when scan screen is done.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                        self?.displayNoScreenPopup()
                    })
                }
            }
        case .denied:
            self.presentManuallyActionsPopup()
        default:
            return
        }
    }
    
    private func presentManuallyActionsPopup() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let alert = UIAlertController(title: "camera_denied_title".localized, message: "camera_denied_body".localized, preferredStyle: .alert)
        let allowAction = UIAlertAction(title: "camera_denied_allow_access".localized, style: .default, handler: { _ in
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        })
        let manualAction = UIAlertAction(title: "camera_denied_manually_option".localized, style: .default) { [weak self] _ in
            self?.toBrowseBrands()
        }
        alert.addAction(manualAction)
        alert.addAction(allowAction)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
