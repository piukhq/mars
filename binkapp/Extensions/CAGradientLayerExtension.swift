//
//  CAGradientLayerExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 26/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    static let visaPaymentCardGradient = makeGradient(firstColor: .visaGradientLeft, secondColor: .visaGradientRight)
    static let mastercardPaymentCardGradient = makeGradient(firstColor: .mastercardGradientLeft, secondColor: .mastercardGradientRight)
    static let amexPaymentCardGradient = makeGradient(firstColor: .amexGradientLeft, secondColor: .amexGradientRight)
    static let unknownPaymentCardGradient = makeGradient(firstColor: .unknownGradientLeft, secondColor: .unknownGradientRight)
    static let binkSwitchGradient = makeGradient(firstColor: .binkPurple, secondColor: .blueAccent)

    static func makeGradient(firstColor: UIColor, secondColor: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)

        return gradientLayer
    }
    
    static func makeGradient(for view: UIView, firstColor: UIColor, secondColor: UIColor, startPoint: CGPoint = CGPoint(x: 1.0, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)) {
        let gradientLayer = CAGradientLayer()
        view.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [secondColor.cgColor, firstColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
}
