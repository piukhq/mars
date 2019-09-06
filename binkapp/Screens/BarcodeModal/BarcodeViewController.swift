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
    var rightButton: UIBarButtonItem?
    var leftButton: UIBarButtonItem?
    
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
        
        title = viewModel.getTitle()
        
        rightButton = UIBarButtonItem(image: UIImage(named: "close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(maximizeBarcode))
        leftButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))

        navigationItem.leftBarButtonItem = leftButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        originalBarcodeFrame = barcodeImageView.frame
    }
    
    func configureUI() {
        viewModel.generateBarcodeImage(for: barcodeImageView)
        
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
        UIView.animate(withDuration: 0.3, animations: {
            if self.isBarcodeFullsize {
                let orientation = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
                self.setForPortraitOrientation()
            } else {
                let orientation = UIInterfaceOrientation.landscapeRight.rawValue
                UIDevice.current.setValue(orientation, forKey: "orientation")
                self.setForLandscapeOrientation()
            }
        })
        
        isBarcodeFullsize.toggle()
    }
    
    func setForLandscapeOrientation() {
        barcodeImageView.frame = view.frame
        barcodeImageView.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(true, animated: true)
        navigationController?.navigationBar.frame.size.height *= 2
        numberLabel.textColor = .black
        let imageRect = viewModel.getRectOfImageInImageView(imageView: barcodeImageView)
        numberLabel.frame.origin = CGPoint(x: imageRect.origin.x + imageRect.width / 5.5, y: imageRect.origin.y + imageRect.height / 1.6)
        additionalSafeAreaInsets.top = 30
    }
    
    func setForPortraitOrientation() {
        barcodeImageView.frame = originalBarcodeFrame
        barcodeImageView.backgroundColor = .clear
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.setHidesBackButton(false, animated: true)
        navigationController?.navigationBar.frame.size.height /= 2
        numberLabel.textColor = .blueAccent
    }
    
    @objc private func popViewController() {
        dismiss(animated: true, completion: nil)
    }
}
