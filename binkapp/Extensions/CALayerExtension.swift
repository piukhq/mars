//
//  CALayerExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 12/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension CALayer {
    func applyDefaultBinkShadow() {
        applySketchShadow(color: .black, alpha: 0.1, x: 0, y: 3, blur: 22, spread: 0)
    }

    func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0

        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
