//
//  UIApplication+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

extension UIApplication {
    static let bottomSafeArea: CGFloat = {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        return window?.safeAreaInsets.bottom ?? 0
    }()
}
