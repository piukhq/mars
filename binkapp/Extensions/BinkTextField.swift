//
//  BinkTextField.swift
//  binkapp
//
//  Created by Paul Tiriteu on 13/08/2019.
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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 8.0)
        layer.shadowRadius = 10
        layer.masksToBounds = false
        layer.shadowOpacity = 0.1
        layer.backgroundColor = UIColor.white.cgColor
    }
}
