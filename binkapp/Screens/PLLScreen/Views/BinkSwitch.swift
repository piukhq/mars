//
//  BinkSwitch.swift
//  binkapp
//
//  Created by Dorin Pop on 04/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BinkSwitch: UISwitch {
    private let backgroundGradientLayer = CAGradientLayer()
    
    override var isOn: Bool {
        didSet {
            if isOn {
                setGradientLayer()
            }
        }
    }
    var isGradientVisible: Bool? {
        didSet {
            if isGradientVisible ?? false {
                setGradientLayer()
            } else {
                removeGradientLayer()
            }
        }
    }
    
    override func layoutSubviews() {
        backgroundGradientLayer.frame = bounds
        backgroundGradientLayer.colors = UIColor.binkSwitchGradients
        backgroundGradientLayer.locations = [0.0, 1.0]
        backgroundGradientLayer.cornerRadius = frame.height / 2
        backgroundGradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
    }
}

// MARK: - Private methods

private extension BinkSwitch {
    func setGradientLayer() {
        layer.insertSublayer(backgroundGradientLayer, at: 0)
    }
    
    func removeGradientLayer() {
        backgroundGradientLayer.removeFromSuperlayer()
    }
}
