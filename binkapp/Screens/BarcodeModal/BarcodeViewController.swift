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
    
    let viewModel: BarcodeViewModel

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
    }
    
    func configureUI() {
        barcodeImageView.image = viewModel.generateBarcodeImage()
        
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
    }
}
