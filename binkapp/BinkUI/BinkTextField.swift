//
//  BinkTextField.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

class BinkTextField: UITextField {
    private var shadowLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        borderStyle = .none
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor
        layer.masksToBounds = false
        layer.backgroundColor = UIColor.white.cgColor
        layer.applyDefaultBinkShadow()
    }
}
