//
//  BinkSwitch.swift
//  binkapp
//
//  Created by Dorin Pop on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
@IBDesignable

class BinkSwitch: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}


private extension BinkSwitch {
    func setGradientLayer() {
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = bounds
        backgroundGradientLayer.colors = UIColor.binkSwitchGradients
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.cornerRadius = self.frame.size.height / 2
        backgroundGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    func removeGradientLayer(){
        if let sublayers = layer.sublayers, sublayers.count > 1 {
            for layer in sublayers {
                layer.removeFromSuperlayer()
                break
            }
        }
    }
}
