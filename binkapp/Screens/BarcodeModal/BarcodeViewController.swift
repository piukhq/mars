//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BarcodeViewController: UIViewController {
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var maximiseButton: BinkGradientButton!
    
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
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal)
        self.title = viewModel.getTitle()
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
        descriptionLabel.text = "barcode_card_description".localized
        descriptionLabel.textAlignment = .justified

//        maximiseButton.setGradientBackground(firstColor: UIColor(red: 180/255, green: 111/255, blue: 234/255, alpha: 1), secondColor: UIColor.blueAccent)
//        maximiseButton.layer.cornerRadius = maximiseButton.frame.size.height / 2
//        maximiseButton.addShadow(shadowColor: UIColor.black.cgColor, shadowOffset: CGSize(width: 0.0, height: 8.0), shadowOpacity: 0.3, shadowRadius: 8.0)
//        maximiseButton.layer.masksToBounds = false
//        maximiseButton.clipsToBounds = true
//        
//        maximiseButton.layer.shadowColor = UIColor.black.cgColor
//        maximiseButton.layer.shadowOpacity = 0.3
//        maximiseButton.layer.shadowOffset = CGSize(width: 1, height: 8)
//        maximiseButton.layer.shadowRadius = 8
//        maximiseButton.layer.shadowPath = UIBezierPath(rect: maximiseButton.bounds).cgPath
//        maximiseButton.layer.shouldRasterize = true
//        
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
}
