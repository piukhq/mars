//
//  CGFloatExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 15/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

extension CGFloat {
    static func onePointScaled() -> CGFloat {
        return 1 / UIScreen.main.scale
    }
}
