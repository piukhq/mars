//
//  FloatExtension.swift
//  binkapp
//
//  Created by Paul Tiriteu on 08/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

extension Float {
    var hasDecimals: Bool {
        return self - self.rounded(.down) > 0
    }
}
