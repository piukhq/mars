//
//  Array+Swift.swift
//  binkapp
//
//  Created by Max Woodhams on 15/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}
