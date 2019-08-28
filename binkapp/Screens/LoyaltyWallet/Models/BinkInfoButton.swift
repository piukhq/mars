//
//  BinkInfoButton.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BinkInfoButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        tintColor = UIColor.blueAccent
        titleLabel?.font = UIFont.linkTextButtonNormal
        setTitleColor(UIColor.blueAccent, for: .normal)
        
        if imageView != nil {
            imageEdgeInsets = UIEdgeInsets(top: 8, left: 5, bottom: 7, right: 5)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        }
    }
}
