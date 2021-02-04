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
        
        semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        tintColor = UIColor.blueAccent
        titleLabel?.font = UIFont.linkTextButtonNormal
        setTitleColor(UIColor.blueAccent, for: .normal)
        
        if imageView != nil {
            imageEdgeInsets = LayoutHelper.BinkInfoButton.imageEdgeInsets
            titleEdgeInsets = LayoutHelper.BinkInfoButton.titleEdgeInsets
        }
    }
}
