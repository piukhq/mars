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

    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .buttonText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setGradientBackground(firstColor: .binkPurple, secondColor: .blueAccent, orientation: .horizontal, roundedCorner: true)
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
}
