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
    }
    
    enum CellType {
        case titleSubtitle
        case segmentedControl
    }

    typealias DebugRowAction = () -> Void
    
    let title: String
    let subtitle: String?
    let action: DebugRowAction?
    let cellType: CellType
    
    init(title: String = "", subtitle: String? = nil, action: DebugRowAction? = nil, cellType: CellType) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.cellType = cellType
    }
}
