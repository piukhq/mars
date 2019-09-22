//
//  BinkGradientButton.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkGradientButton: UIButton {
    private var shadowLayer: CAShapeLayer!
    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .buttonText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .white
        processGradient(.binkPurple, .blueAccent)
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
    }
    
    override var isEnabled: Bool {
        didSet {
            gradientLayer.opacity = isEnabled ? 1.0 : 0.5
        }
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
