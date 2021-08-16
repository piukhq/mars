//
//  SchemeUtil.swift
//  binkapp
//
//  Created by Sean Williams on 16/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

enum SchemeUtil {
    static func isDebug() -> Bool {
        if let schemeName = Bundle.main.infoDictionary?["CURRENT_SCHEME_NAME"] as? String {
            return schemeName == "Bink-Beta" || schemeName == "Bink-Alpha"
        }
        return false
    }
}
