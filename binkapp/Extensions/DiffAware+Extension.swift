//
//  DiffAware+Extension.swift
//  binkapp
//
//  Created by Max Woodhams on 12/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import DeepDiff

extension DiffAware where Self: Hashable {
    var diffId: Int {
        return hashValue
    }
    
    static func compareContent(_ a: Self, _ b: Self) -> Bool {
        return a == b
    }
}
