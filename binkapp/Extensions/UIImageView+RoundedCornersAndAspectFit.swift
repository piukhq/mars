//
//  UIImageView+RoundedCornersAndAspectFit.swift
//  binkapp
//
//  Created by Paul Tiriteu on 23/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func roundCornersForAspectFit(radius: CGFloat) {
        if let image = self.image {
            let boundsScale = bounds.size.width / bounds.size.height
            let imageScale = image.size.width / image.size.height

            var drawingRect: CGRect = bounds

            if boundsScale > imageScale {
                drawingRect.size.width = drawingRect.size.height * imageScale
                drawingRect.origin.x = (bounds.size.width - drawingRect.size.width) / 2
            } else {
                drawingRect.size.height = drawingRect.size.width / imageScale
                drawingRect.origin.y = (bounds.size.height - drawingRect.size.height) / 2
            }
            let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
