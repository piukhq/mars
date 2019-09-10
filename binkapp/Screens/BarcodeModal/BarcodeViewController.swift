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
    @IBOutlet weak var barcodeImageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var barcodeImageViewTrailingConstraint: NSLayoutConstraint!
    
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
        
        title = viewModel.getTitle()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .white
        
        if isBarcodeFullsize {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureUI(maximised: isBarcodeFullsize)
    }
    
    func configureUI(maximised: Bool) {
        viewModel.generateBarcodeImage(for: barcodeImageView)
        
        barcodeImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(maximizeBarcode))
        barcodeImageView.addGestureRecognizer(tap)
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = UIColor.black
        titleLabel.text = "card_number_title".localized
        titleLabel.isHidden = maximised
        labelStackView.setCustomSpacing(0.0, after: titleLabel)
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = maximised ? .black : UIColor.blueAccent
        numberLabel.text = viewModel.getCardNumber()
        
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.textAlignment = .justified
        descriptionLabel.isHidden = maximised
        
        switch viewModel.getBarcodeType() {
        case .loyaltyCard:
            descriptionLabel.text = "barcode_card_description".localized
        case .coupon:
            descriptionLabel.text = "barcode_coupon_description".localized
        }
        
        maximiseButton.isHidden = maximised
        maximiseButton.setTitleColor(UIColor.white, for: .normal)
        maximiseButton.titleLabel?.font = UIFont.subtitle
        maximiseButton.setTitle("barcode_maximise_button".localized, for: .normal)
    }
    
    @objc func maximizeBarcode() {
        // If we are the maximised kind, dismiss this view. If not, present a new barcode modal but maximised
        if isBarcodeFullsize {
            navigationController?.dismiss(animated: true)
        } else {
            let nav = UINavigationController(rootViewController: BarcodeViewController(viewModel: viewModel, showFullSize: true))
            nav.modalTransitionStyle = .crossDissolve
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
