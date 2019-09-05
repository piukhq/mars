//
//  UserDefaultsExtension.swift
//  binkapp
//
//  Created by Nick Farrant on 05/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case userEmail
    }

    func setValue(_ value: Any?, forKey key: Key) {
        setValue(value, forKey: key.rawValue)
    }

    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
}
