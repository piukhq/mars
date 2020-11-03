//
//  LCDPlaceholderGenerator.swift
//  binkapp
//
//  Created by Max Woodhams on 29/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum LCDPlaceholderGenerator {
    /// Although this is the preferred option, this is still dependent on an API call to retrieve the icon image
    static func generate(with colorHexString: String, iconImage: UIImage, destSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: destSize)
        let shouldForceWhite = iconImage.isTransparent()

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor(hexString: colorHexString).cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: destSize.width, height: destSize.height))
            
            let iconImageSize = CGSize(width: 60, height: 60)
            let padding = destSize.width * 0.075
            let xStart = padding
            let yStart = padding
            
            let blendMode: CGBlendMode = shouldForceWhite ? .destinationOut : .normal
            
            iconImage.draw(in: CGRect(x: xStart, y: yStart, width: iconImageSize.width, height: iconImageSize.height), blendMode: blendMode, alpha: 1.0)
        }
        
        return img
    }
    
    static func generate(with colorHexString: String, planName: String, destSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: destSize)
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor(hexString: colorHexString).cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: destSize.width, height: destSize.height))
            
            let padding = destSize.width * 0.06
            let xStart = padding
            let yStart = padding
            
            let attributes = [NSAttributedString.Key.font: UIFont.subtitle, NSAttributedString.Key.foregroundColor: UIColor.white ]
            let planNameAttributed = NSAttributedString(string: planName, attributes: attributes)
                        
            planNameAttributed.draw(at: CGPoint(x: xStart, y: yStart))
        }
        
        return img
    }
}
