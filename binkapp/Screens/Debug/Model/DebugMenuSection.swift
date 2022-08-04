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

struct DebugMenuRow: Equatable {
    static func == (lhs: DebugMenuRow, rhs: DebugMenuRow) -> Bool {
        return lhs.title == rhs.title
    }
    
    enum RowType {
        case version
        case email
        case endpoint
        case secondaryColor
        case lpcDebugMode
        case responseCodeVisualiser
        case inAppReviewRules
        case customBundleClientLogin
    }
    
    enum CellType: Equatable {
        case titleSubtitle
        case segmentedControl
        case picker(PromptType?)
    }

    enum PromptType {
        case link
        case see
        case store
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
