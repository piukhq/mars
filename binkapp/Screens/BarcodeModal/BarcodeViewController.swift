//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BarcodeViewController: BinkTrackableViewController {
    @IBOutlet private weak var barcodeImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var maximiseButton: BinkGradientButton!
    
    private let viewModel: BarcodeViewModel
    var hasDrawnBarcode = false
    
    init(viewModel: BarcodeViewModel, showFullSize: Bool = false) {
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popViewController))
        
        configureUI()
    }
    
    func configureUI() {
        guard !hasDrawnBarcode else { return }
        
        viewModel.generateBarcodeImage(for: barcodeImageView)

        barcodeImageView.isHidden = !viewModel.isBarcodeAvailable
        numberLabel.isHidden = viewModel.cardNumber == nil
        maximiseButton.isHidden = !viewModel.isBarcodeAvailable
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = .black
        titleLabel.text = "card_number_title".localized
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = .blueAccent
        numberLabel.text = viewModel.cardNumber
        
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.textColor = .black
        descriptionLabel.textAlignment = .justified
        
        switch viewModel.barcodeType {
        case .loyaltyCard:
            if viewModel.isBarcodeAvailable {
                descriptionLabel.text = "barcode_card_description".localized
            } else {
                descriptionLabel.text = "barcode_card_number_description".localized
            }
        case .coupon:
            descriptionLabel.text = "barcode_coupon_description".localized
        }

        maximiseButton.setTitleColor(.white, for: .normal)
        maximiseButton.titleLabel?.font = UIFont.subtitle
        maximiseButton.setTitle("barcode_maximise_button".localized, for: .normal)
        maximiseButton.addTarget(self, action: #selector(maximizeButtonPressed), for: .touchUpInside)

        hasDrawnBarcode = true

        maximiseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            maximiseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            maximiseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            maximiseButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            maximiseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func popViewController() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func maximizeButtonPressed() {
        let vc = BarcodeMaximizedViewController(barcodeImage: barcodeImageView.image, planName: viewModel.title, cardNumber: viewModel.cardNumber)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
}
