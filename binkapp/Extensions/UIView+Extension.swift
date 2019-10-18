//
//  UIView+Extension.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    enum GradientOrientation {
        case vertical
        case horizontal
    }
    
    func setGradientBackground(firstColor: UIColor, secondColor: UIColor, orientation: GradientOrientation, roundedCorner: Bool) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = orientation == .horizontal ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = orientation == .horizontal ? CGPoint(x: 0.0, y: 0.0) : CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = roundedCorner ? frame.size.height / 2 : 0
        
        layer.insertSublayer(gradientLayer, at: 0)
    }

    static func fromNib<T: UIView>() -> T {
        guard let viewFromNib = Bundle.main.loadNibNamed(String(describing: T.self), owner: self, options: nil)?.first as? T else {
            fatalError("Could not load view from nib")
        }
        return viewFromNib
    }
}
