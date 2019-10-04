//
//  RectangleView.swift
//  binkapp
//
//  Created by Nick Farrant on 01/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class RectangleView: UIView {

    var firstColorHex: String = "#D3D3D3" {
        didSet {
            setNeedsDisplay()
        }
    }

    var secondColorHex: String = "#888888"

    override func draw(_ rect: CGRect) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!

        /// Color Declarations
        let firstColor = UIColor(hexString: firstColorHex)
        let secondColor = UIColor(hexString: secondColorHex)

        /// Rectangle Drawing
        context.saveGState()
        context.translateBy(x: 120.76, y: 81.4)
        context.rotate(by: -45 * CGFloat.pi/180)

        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: -15, y: -5, width: 427.54, height: 333.64), cornerRadius: 12)
        secondColor.setFill()
        rectanglePath.fill()

        context.restoreGState()

        /// Rectangle 2 Drawing
        context.saveGState()
        context.translateBy(x: 134, y: 38.72)
        context.rotate(by: -20 * CGFloat.pi/180)

        let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: -15, y: -5, width: 514.29, height: 370.52), cornerRadius: 12)
        firstColor.setFill()
        rectangle2Path.fill()

        context.restoreGState()
    }
}
