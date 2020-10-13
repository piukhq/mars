//
//  BarcodeViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BarcodeViewController: BinkTrackableViewController {
    
    struct Constants {
        static let largeSpace: CGFloat = 20
        static let smallSpace: CGFloat = -5
    }
    
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var barcodeImageView: UIImageView!
    @IBOutlet private weak var barcodeErrorLabel: UILabel!
    @IBOutlet private weak var barcodeLabel: UILabel!
    @IBOutlet private weak var barcodeNumberLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private var previousBrightness: CGFloat?
    private var viewToCopy: UIView!

    private let viewModel: BarcodeViewModel
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
        
        barcodeImageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(presentMenuController)))
        
        barcodeLabel.font = UIFont.headline
        barcodeLabel.textColor = .black
        barcodeLabel.text = viewModel.isBarcodeAvailable ? "barcode_title".localized : nil
        
        barcodeNumberLabel.font = UIFont.subtitle
        barcodeNumberLabel.textColor = .black
        barcodeNumberLabel.text = viewModel.barcodeNumber
        barcodeNumberLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(presentMenuController)))

        
        titleLabel.font = UIFont.headline
        titleLabel.textColor = .black
        titleLabel.text = "card_number_title".localized
        
        numberLabel.font = UIFont.subtitle
        numberLabel.textColor = .blueAccent
        numberLabel.text = viewModel.cardNumber
        numberLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(presentMenuController)))
        
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
    
    @objc private func presentMenuController(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .recognized else { return }

        if let recognizerView = recognizer.view, let recognizerSuperView = recognizerView.superview {
            recognizerView.becomeFirstResponder()
            viewToCopy = recognizerView
            let menu = UIMenuController.shared
            menu.arrowDirection = .up
            
            let width = recognizerView.intrinsicContentSize.width / 2
            let height = recognizerView == barcodeImageView ? recognizerView.frame.maxY - 5 : recognizerView.center.y + 4
            let rect = CGRect(x: width, y: height, width: 0.0, height: 0.0)

            if !menu.isMenuVisible {
                menu.setTargetRect(rect, in: recognizerSuperView)
                menu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
          return action == #selector(UIResponderStandardEditActions.copy)
      }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = viewToCopy == numberLabel ? numberLabel.text : barcodeNumberLabel.text
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
