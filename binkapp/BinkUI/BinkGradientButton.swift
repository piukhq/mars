//
//  BinkGradientButton.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkGradientButton: BinkPillButton {
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

    private lazy var whiteLayer: CALayer = {
        let whiteLayer = CALayer()
        layer.insertSublayer(whiteLayer, at: 0)
        return whiteLayer
    }()
    
    override var isEnabled: Bool {
        didSet {
            gradientLayer.opacity = isEnabled ? 1.0 : 0.5
        }
    }

    override func layoutSubviews() {
        // We need to process the gradient before we process the shadow
        // So we call super.layoutSubviews last
        processGradient(.binkPurple, .blueAccent)
        super.layoutSubviews()
        setWhiteLayer()
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: .outageError, object: nil)
    }

    func configure(title: String, hasShadow: Bool = true) {
        setTitle(title, for: .normal)
        self.hasShadow = hasShadow
    }
    
    private func setWhiteLayer() {
        whiteLayer.frame = bounds
        whiteLayer.backgroundColor = UIColor.white.cgColor
        whiteLayer.cornerRadius = self.frame.size.height / 2
    }

    private func processGradient(_ firstColor: UIColor, _ secondColor: UIColor) {
        gradientLayer.frame = bounds
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = self.frame.size.height / 2
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
}

class BinkMiniGradientButton: BinkGradientButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = .miniButtonText
    }
}
