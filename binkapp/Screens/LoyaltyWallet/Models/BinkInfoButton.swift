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
        accessibilityIdentifier = "Bink info button"
        
        if imageView != nil {
            imageEdgeInsets = LayoutHelper.BinkInfoButton.imageEdgeInsets
            titleEdgeInsets = LayoutHelper.BinkInfoButton.titleEdgeInsets
        }
    }
}
