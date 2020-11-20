//
//  OptionalExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 20/11/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        guard let array = self else { return true }
        return array.isEmpty
    }
}
