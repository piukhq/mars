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
    @IBOutlet private weak var labelStackView: UIStackView!
    @IBOutlet private weak var barcodeStackView: UIStackView!
    @IBOutlet private weak var minimizeButton: UIButton!
    @IBOutlet private weak var maximizedTitleLabel: UILabel!
    @IBOutlet private weak var labelStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var labelStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var barcodeStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var labelCenterVerticallyConstraint: NSLayoutConstraint!
    @IBOutlet private var barcodeCenterVerticallyConstraint: NSLayoutConstraint!
    
    private let viewModel: BarcodeViewModel
    var isBarcodeFullsize = false
    var hasDrawnBarcode = false
    
    private struct Constants {
        static let marginDefaultConstant: CGFloat = 25
        static let maximizedLeadingConstraint: CGFloat = -10
        static let labelTrailingInset: CGFloat = 200.0
    }
    
    @IBAction func maximiseButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.maximizeContent()
        }) {[weak self] _ in
            self?.navigationController?.navigationBar.isHidden = true
        }
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(popViewController))
        
        configureUI()
    }
    
    func configureUI() {
        guard !hasDrawnBarcode else { return }
        
        viewModel.generateBarcodeImage(for: barcodeImageView)
        barcodeImageView.isHidden = !viewModel.isBarcodeAvailable
        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = .black
        titleLabel.text = "card_number_title".localized
        labelStackView.setCustomSpacing(0.0, after: titleLabel)
        
        labelStackView.alignment = .fill
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = .blueAccent
        
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
        
        maximiseButton.isHidden = !viewModel.isBarcodeAvailable 
        maximiseButton.setTitleColor(.white, for: .normal)
        maximiseButton.titleLabel?.font = UIFont.subtitle
        maximiseButton.setTitle("barcode_maximise_button".localized, for: .normal)
        hasDrawnBarcode = true
        
        minimizeButton.alpha = 0
        maximizedTitleLabel.text = viewModel.title
        maximizedTitleLabel.transform = barcodeImageView.transform.rotated(by: CGFloat.pi / 2)
        maximizedTitleLabel.alpha = 0
        maximizedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        maximiseButton.translatesAutoresizingMaskIntoConstraints = false
        labelCenterVerticallyConstraint.isActive = false
        NSLayoutConstraint.activate([
            maximiseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            maximiseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            maximiseButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            maximiseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maximizedTitleLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        numberLabel.isHidden = viewModel.cardNumber == nil
        numberLabel.text = viewModel.cardNumber
        
    }
    
    private func maximizeContent() {
        navigationController?.navigationBar.alpha = 0
        numberLabel.textColor = .black
        labelStackView.alignment = .center
        titleLabel.isHidden = true
        descriptionLabel.isHidden = true
        maximiseButton.alpha = 0
        minimizeButton.alpha = 1
        maximizedTitleLabel.alpha = 1
        labelStackView.transform = labelStackView.transform.rotated(by: CGFloat.pi / 2)
        barcodeStackView.transform = barcodeStackView.transform.rotated(by: CGFloat.pi / 2)
        labelStackViewLeadingConstraint.constant = Constants.maximizedLeadingConstraint
        labelStackViewTrailingConstraint.constant = labelStackView.frame.size.width + Constants.labelTrailingInset
        labelStackViewTrailingConstraint.priority = .defaultLow
        labelStackViewTopConstraint.priority = .defaultLow
        barcodeStackViewTopConstraint.priority = .defaultLow
        barcodeCenterVerticallyConstraint.priority = .defaultHigh
        labelCenterVerticallyConstraint.isActive = true
        barcodeCenterVerticallyConstraint.isActive = true
    }
    
    private func minimizeContent() {
        navigationController?.navigationBar.alpha = 1
        titleLabel.isHidden = false
        descriptionLabel.isHidden = false
        minimizeButton.alpha = 0
        maximiseButton.alpha = 1
        numberLabel.textColor = .blue
        maximizedTitleLabel.alpha = 0
        labelStackView.alignment = .fill
        barcodeCenterVerticallyConstraint.priority = .defaultLow
        labelStackViewTrailingConstraint.priority = .defaultHigh
        labelStackViewTopConstraint.priority = .defaultHigh
        barcodeStackViewTopConstraint.priority = .defaultHigh
        labelStackView.transform = labelStackView.transform.rotated(by: -(CGFloat.pi / 2))
        barcodeStackView.transform = barcodeStackView.transform.rotated(by: -(CGFloat.pi / 2))
        labelCenterVerticallyConstraint.isActive = false
        barcodeCenterVerticallyConstraint.isActive = false
        barcodeStackViewTopConstraint.constant = LayoutHelper.heightForNavigationBar(navigationController?.navigationBar)
        labelStackViewLeadingConstraint.constant = Constants.marginDefaultConstant
        labelStackViewTrailingConstraint.constant = Constants.marginDefaultConstant
        labelStackViewTopConstraint.constant = 0
    }
    
    @IBAction func minimiseBarcode(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.minimizeContent()
        }) { [weak self] _ in
            self?.navigationController?.navigationBar.isHidden = false
        }
    }
    
    @objc private func popViewController() {
        dismiss(animated: true, completion: nil)
    }
}
