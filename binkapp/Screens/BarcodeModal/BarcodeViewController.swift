//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BarcodeViewController: BinkViewController {
    enum Constants {
        static let largeSpace: CGFloat = 20
        static let smallSpace: CGFloat = -5
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var barcodeErrorLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var barcodeNumberLabel: BinkCopyableLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: BinkCopyableLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var previousBrightness: CGFloat?

    let viewModel: BarcodeViewModel
    var hasDrawnBarcode = false
    
    init(viewModel: BarcodeViewModel) {
        self.viewModel = viewModel
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
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        previousBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = previousBrightness ?? 0.5
    }
    
    func configureUI() {
        guard !hasDrawnBarcode else { return }
        barcodeImageView.isHidden = !viewModel.isBarcodeAvailable
        [numberLabel, titleLabel].forEach {
            $0?.isHidden = viewModel.cardNumber == nil
        }
        
        stackView.setCustomSpacing(Constants.largeSpace, after: barcodeImageView)
        stackView.setCustomSpacing(Constants.smallSpace, after: barcodeLabel)
        stackView.setCustomSpacing(Constants.smallSpace, after: titleLabel)
        stackView.setCustomSpacing(Constants.largeSpace, after: numberLabel.isHidden ? barcodeNumberLabel : numberLabel)
        
        if let barcodeImage = viewModel.barcodeImage(withSize: barcodeImageView.frame.size) {
            barcodeImageView.isHidden = false
            barcodeErrorLabel.isHidden = true
            barcodeImageView.image = barcodeImage
        } else {
            barcodeImageView.isHidden = true
            barcodeErrorLabel.text = "barcode_error".localized
            barcodeErrorLabel.font = UIFont.bodyTextLarge
            barcodeErrorLabel.isHidden = viewModel.isBarcodeAvailable ? false : true
        }
                
        barcodeLabel.font = UIFont.headline
        barcodeLabel.textColor = .black
        barcodeLabel.text = viewModel.isBarcodeAvailable ? "barcode_title".localized : nil
        
        barcodeNumberLabel.font = UIFont.subtitle
        barcodeNumberLabel.textColor = .black
        barcodeNumberLabel.text = viewModel.barcodeNumber
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = .black
        titleLabel.text = "card_number_title".localized
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = .blueAccent
        numberLabel.text = viewModel.cardNumber
        
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .justified
        
        switch viewModel.barcodeUse {
        case .loyaltyCard:
            if viewModel.isBarcodeAvailable {
                descriptionLabel.text = "barcode_card_description".localized
            } else {
                descriptionLabel.text = "barcode_card_number_description".localized
            }
        case .coupon:
            descriptionLabel.text = "barcode_coupon_description".localized
        }

        hasDrawnBarcode = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
