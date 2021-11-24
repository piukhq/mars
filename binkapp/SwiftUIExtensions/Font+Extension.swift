//
//  Font+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 14/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

extension Font {
    static func nunitoSemiBold(_ size: CGFloat) -> Font {
        return .custom("NunitoSans-SemiBold", size: size)
    }
    
    static func nunitoBold(_ size: CGFloat) -> Font {
        return .custom("NunitoSans-Bold", size: size)
    }
}
