//
//  DictionaryExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 23/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(dict: [Key: Value]) {
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
