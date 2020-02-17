//
//  DebugMenuSection.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct DebugMenuSection {
    let title: String
    let rows: [DebugMenuRow]
}

struct DebugMenuRow {
    enum RowType {
        case version
        case email
        case endpoint
        case mockBKWallet
    }

    typealias DebugRowAction = () -> Void
    
    let title: String
    let subtitle: String?
    let action: DebugRowAction?
}
