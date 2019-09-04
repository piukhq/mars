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
    
    let viewModel: BarcodeViewModel
    var originalBarcodeFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var isBarcodeFullsize = false
    
    @IBAction func maximiseButtonAction(_ sender: Any) {
        maximizeBarcode()
    }
    
    init(viewModel: BarcodeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "BarcodeViewController", bundle: Bundle(for: BarcodeViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .white
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        
        title = viewModel.getTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        originalBarcodeFrame = barcodeImageView.frame
    }
    
    func configureUI() {
        barcodeImageView.image = viewModel.generateBarcodeImage()
        
        barcodeImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(maximizeBarcode))
        barcodeImageView.addGestureRecognizer(tap)
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = UIColor.black
        titleLabel.text = "card_number_title".localized
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = UIColor.blueAccent
        numberLabel.text = viewModel.getCardNumber()
        
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.textAlignment = .justified

        switch viewModel.getBarcodeType() {
        case .loyaltyCard:
            descriptionLabel.text = "barcode_card_description".localized
        case .coupon:
            descriptionLabel.text = "barcode_coupon_description".localized
        }

        maximiseButton.setTitleColor(UIColor.white, for: .normal)
        maximiseButton.titleLabel?.font = UIFont.subtitle
        maximiseButton.setTitle("barcode_maximise_button".localized, for: .normal)
    }
    
    @objc func maximizeBarcode() {
        UIView.animate(withDuration: 0.5, animations: {
            if self.isBarcodeFullsize {
                self.barcodeImageView.frame = self.originalBarcodeFrame
                self.barcodeImageView.backgroundColor = .clear
            } else {
                self.barcodeImageView.frame = self.view.bounds
                self.barcodeImageView.backgroundColor = .white
            }
        })
        
        isBarcodeFullsize.toggle()
    }
    
    @objc private func popViewController() {
        dismiss(animated: true, completion: nil)
    }
}
