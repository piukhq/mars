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
}
