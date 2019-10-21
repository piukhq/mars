//
//  BinkPillButton.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BinkPillButton: UIButton {
    enum PillButtonType {
        case facebook
    }

    private var shadowLayer: CAShapeLayer!

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        return activityIndicator
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .buttonText
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let halfOfButtonHeight = layer.frame.height / 2
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: halfOfButtonHeight).cgPath
            shadowLayer.fillColor = UIColor.clear.cgColor

            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 3, height: 8)
            shadowLayer.shadowOpacity = 0.2
            shadowLayer.shadowRadius = 10

            layer.insertSublayer(shadowLayer, at: 0)
        }

        layer.cornerRadius = halfOfButtonHeight

        setupActivityIndicator()
    }

    func configureForType(_ type: PillButtonType) {
        backgroundColor = backgroundColor(forType: type)
        setTitle(title(forType: type), for: .normal)
    }

    func startLoading() {
        titleLabel?.alpha = 0.0
        activityIndicator.startAnimating()
    }

    func stopLoading() {
        titleLabel?.alpha = 1.0
        activityIndicator.stopAnimating()
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func backgroundColor(forType buttonType: PillButtonType) -> UIColor {
        switch buttonType {
        case .facebook:
            return .init(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
        }
    }

    private func title(forType buttonType: PillButtonType) -> String {
        switch buttonType {
        case .facebook:
            return "Continue with Facebook"
        }
    }
}

extension LayoutHelper {
    struct PillButton {
        static let height: CGFloat = 52
        static let width: CGFloat = 300
        static let verticalSpacing: CGFloat = 25
        static let bottomPadding: CGFloat = 16
    }
}
