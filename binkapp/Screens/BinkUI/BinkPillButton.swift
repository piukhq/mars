//
//  BinkPillButton.swift
//  binkapp
//
//  Created by Nick Farrant on 21/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BinkPillButton: BinkTrackableButton {
    enum PillButtonType {
        case facebook
    }

    var hasShadow = true
    private var shadowLayer: CAShapeLayer!

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        return activityIndicator
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(.white, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let halfOfButtonHeight = layer.frame.height / 2
        if shadowLayer == nil && hasShadow {
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
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }

        setupActivityIndicator()
    }

    func configureForType(_ type: PillButtonType, hasShadow: Bool = true) {
        backgroundColor = backgroundColor(forType: type)
        setTitle(title(forType: type), for: .normal)
        titleLabel?.font = .buttonText
        self.hasShadow = hasShadow
    }

    func startLoading() {
        setTitleColor(.clear, for: .normal)
        activityIndicator.startAnimating()
    }

    func stopLoading() {
        setTitleColor(.white, for: .normal)
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
            return .facebookButton
        }
    }

    private func title(forType buttonType: PillButtonType) -> String {
        switch buttonType {
        case .facebook:
            return "continue_with_facebook_button".localized
        }
    }
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if !activityIndicator.isAnimating {
            super.sendAction(action, to: target, for: event)
        }
    }
}

class BinkMiniPillButton: BinkPillButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = .miniButtonText
    }
}

extension LayoutHelper {
    enum PillButton {
        static let height: CGFloat = 52
        static let cornerRadius: CGFloat = PillButton.height / 2
        static let widthPercentage: CGFloat = 0.75
        static let verticalSpacing: CGFloat = 25
        static let bottomPadding: CGFloat = 50
    }
}
