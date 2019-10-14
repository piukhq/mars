//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BarcodeViewController: UIViewController {
    @IBOutlet private weak var barcodeImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var maximiseButton: BinkGradientButton!
    @IBOutlet private weak var labelStackView: UIStackView!
    
    private let viewModel: BarcodeViewModel
    var isBarcodeFullsize = false
    
    @IBAction func maximiseButtonAction(_ sender: Any) {
        maximizeBarcode()
    }
    
    init(viewModel: BarcodeViewModel, showFullSize: Bool = false) {
        self.viewModel = viewModel
        isBarcodeFullsize = showFullSize
        super.init(nibName: "BarcodeViewController", bundle: Bundle(for: BarcodeViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .white
        
        if isBarcodeFullsize {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popViewController))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureUI(maximized: isBarcodeFullsize)
    }
    
    func configureUI(maximized: Bool) {
        viewModel.generateBarcodeImage(for: barcodeImageView)
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = .black
        titleLabel.text = "card_number_title".localized
        titleLabel.isHidden = maximized
        labelStackView.setCustomSpacing(0.0, after: titleLabel)
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = maximized ? .black : .blueAccent
        numberLabel.text = viewModel.getCardNumber()
        
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .justified
        descriptionLabel.isHidden = maximized
        
        switch viewModel.getBarcodeType() {
        case .loyaltyCard:
            descriptionLabel.text = "barcode_card_description".localized
        case .coupon:
            descriptionLabel.text = "barcode_coupon_description".localized
        }
        
        maximiseButton.isHidden = maximized
        maximiseButton.setTitleColor(.white, for: .normal)
        maximiseButton.titleLabel?.font = UIFont.subtitle
        maximiseButton.setTitle("barcode_maximise_button".localized, for: .normal)
        
        if isBarcodeFullsize {
            numberLabel.center.x = barcodeImageView.center.x
        }
    }
    
    func maximizeBarcode() {
        // If we are the maximised kind, dismiss this view. If not, present a new barcode modal but maximised
        if isBarcodeFullsize {
            navigationController?.dismiss(animated: true)
        } else {
            let nav = UINavigationController(rootViewController: BarcodeViewController(viewModel: viewModel, showFullSize: true))
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    @objc private func popViewController() {
        dismiss(animated: true, completion: nil)
    }
}
