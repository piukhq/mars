//
//  UIImage+Extension.swift
//  binkapp
//
//  Created by Max Woodhams on 29/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

extension UIImage {
    public func isTransparent() -> Bool {
        guard let alpha: CGImageAlphaInfo = self.cgImage?.alphaInfo else { return false }
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
    
    public func ciImage() -> CIImage? {
        if let cgImage = cgImage {
            return CoreImage.CIImage(cgImage: cgImage)
        }
        return nil
    }
    
    public func grayScale() -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: bitmapInfo.rawValue)
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context?.draw(cgImage, in: imageRect)
        
        if let imageRef = context?.makeImage() {
            return UIImage(cgImage: imageRef)
        }
        return nil
    }
}
