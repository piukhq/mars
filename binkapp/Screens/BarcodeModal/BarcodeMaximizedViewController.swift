//
//  BarcodeMaximizedViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 20/02/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class BarcodeMaximizedViewController: UIViewController {
    @IBOutlet private var barcodeImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var cardNumberLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!

    private let barcodeImage: UIImage?
    private let planName: String
    private let cardNumber: String?

    struct Constants {
        static let textWidthMultiplier: CGFloat = 0.2
        static let barcodeWidthMultiplier: CGFloat = 0.6
        static let titleY: CGFloat = 0.8
        static let cardNumberY: CGFloat = 0
        static let barcodeY: CGFloat = 0.2
        static let closeButtonHeight: CGFloat = 50
        static let closeButtonMultiplier: CGFloat = 0.2
    }

    init(barcodeImage: UIImage?, planName: String, cardNumber: String?) {
        self.barcodeImage = barcodeImage
        self.planName = planName
        self.cardNumber = cardNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        barcodeImageView.image = barcodeImage

        titleLabel.text = planName
        titleLabel.font = .navbarHeaderLine1

        cardNumberLabel.text = cardNumber
        cardNumberLabel.font = .headline

        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    private func configureUI() {
        barcodeImageView.transform = barcodeImageView.transform.rotated(by: CGFloat.pi / 2)
        titleLabel.transform = titleLabel.transform.rotated(by: CGFloat.pi / 2)
        cardNumberLabel.transform = cardNumberLabel.transform.rotated(by: CGFloat.pi / 2)

        barcodeImageView.frame = CGRect(x: view.frame.width * Constants.textWidthMultiplier, y: 0, width: view.frame.width * Constants.barcodeWidthMultiplier, height: view.frame.height)
        titleLabel.frame = CGRect(x: view.frame.width * Constants.titleY, y: 0, width: view.frame.width * Constants.textWidthMultiplier, height: view.frame.height)
        cardNumberLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width * Constants.textWidthMultiplier, height: view.frame.height)

        let window = UIApplication.shared.keyWindow
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        closeButton.frame = CGRect(x: titleLabel.frame.origin.x, y: view.frame.height - Constants.closeButtonHeight - bottomPadding, width: view.frame.width * Constants.closeButtonMultiplier, height: Constants.closeButtonHeight)
    }

    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

}
