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
        layer.borderColor = Current.themeManager.color(for: .walletCardBackground).cgColor
        layer.masksToBounds = false
        layer.backgroundColor = Current.themeManager.color(for: .walletCardBackground).cgColor
        layer.applyDefaultBinkShadow()
        
        textColor = Current.themeManager.color(for: .text)
        tintColor = Current.themeManager.color(for: .text)
    }
}
