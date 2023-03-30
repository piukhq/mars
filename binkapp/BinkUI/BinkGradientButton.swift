//
//  BinkGradientButton.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkGradientButton: BinkPillButton {
    private lazy var backgroundLayer: CALayer = {
        let gradient = CALayer()
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
            backgroundLayer.opacity = isEnabled ? 1.0 : 0.5
            setTitleColor(isEnabled ? .white : UIColor.white.withAlphaComponent(0.5), for: .normal)
        }
    }

    override func layoutSubviews() {
        // We need to process the gradient before we process the shadow
        // So we call super.layoutSubviews last
        backgroundLayer.backgroundColor = UIColor.binkBlue.cgColor
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = self.frame.size.height / 2
        backgroundLayer.cornerCurve = .continuous
        super.layoutSubviews()
        setWhiteLayer()
    }

    func configure(title: String, hasShadow: Bool = true) {
        setTitle(title, for: .normal)
        titleLabel?.font = .buttonText
        self.hasShadow = hasShadow
    }
    
    private func setWhiteLayer() {
        whiteLayer.frame = bounds
        whiteLayer.backgroundColor = Current.themeManager.color(for: .viewBackground).cgColor
        whiteLayer.cornerRadius = self.frame.size.height / 2
        whiteLayer.cornerCurve = .continuous
    }
}

class BinkMiniGradientButton: BinkGradientButton {
    override func configure(title: String, hasShadow: Bool = true) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .miniButtonText
        self.hasShadow = hasShadow
    }
}
