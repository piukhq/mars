//
//  UIDeviceExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 09/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
