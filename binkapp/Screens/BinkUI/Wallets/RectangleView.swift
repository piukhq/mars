//
//  RectangleView.swift
//  binkapp
//
//  Created by Nick Farrant on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RectangleView: UIView {
    var firstColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }

    var secondColor: UIColor = .greyFifty {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        /// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { return }

        /// Secondary Rectangle Drawing
        context.saveGState()
        context.translateBy(x: LayoutHelper.RectangleView.secondaryRectX, y: LayoutHelper.RectangleView.secondaryRectY)
        context.rotate(by: LayoutHelper.RectangleView.secondaryRectRotation)

        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: -15, y: -5, width: LayoutHelper.RectangleView.secondaryRectWidth, height: LayoutHelper.RectangleView.secondaryRectHeight), cornerRadius: LayoutHelper.RectangleView.cornerRadius)
        secondColor.setFill()
        rectanglePath.fill()

        context.restoreGState()

        /// Primary Rectangle Drawing
        context.saveGState()
        context.translateBy(x: LayoutHelper.RectangleView.primaryRectX, y: LayoutHelper.RectangleView.primaryRectY)
        context.rotate(by: LayoutHelper.RectangleView.primaryRectRotation)

        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: -15, y: -5, width: LayoutHelper.RectangleView.primaryRectWidth, height: LayoutHelper.RectangleView.primaryRectHeight), cornerRadius: LayoutHelper.RectangleView.cornerRadius)
        firstColor.setFill()
        rectangle2Path.fill()

        context.restoreGState()
    }
}

extension LayoutHelper {
    enum RectangleView {
        static let cornerRadius: CGFloat = 12
        
        static let primaryRectX: CGFloat = 134.0
        static let primaryRectY: CGFloat = 38.72
        static let primaryRectWidth: CGFloat = 514.29
        static let primaryRectHeight: CGFloat = 370.52
        static let primaryRectRotation: CGFloat = -20 * CGFloat.pi / 180

        static let secondaryRectX: CGFloat = 120.76
        static let secondaryRectY: CGFloat = 81.4
        static let secondaryRectWidth: CGFloat = 427.54
        static let secondaryRectHeight: CGFloat = 333.64
        static let secondaryRectRotation: CGFloat = -45 * CGFloat.pi / 180
    }
}
