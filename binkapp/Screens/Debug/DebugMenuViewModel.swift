//
//  DebugMenuViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

struct DebugMenuViewModel {
    let sections: [DebugMenuSection]
    
    init(sections: [DebugMenuSection]) {
        self.sections = sections
    }
    
    var title: String {
        return "Debug Menu"
    }
    
    var sectionsCount: Int {
        return sections.count
    }
    
    var cellHeight: CGFloat {
        return 60
    }
    
    func rowsCount(forSectionAtIndex index: Int) -> Int {
        return sections[index].rows.count
    }
    
    func titleForSection(atIndex index: Int) -> String {
        return sections[index].title
    }
    
    func row(atIndexPath indexPath: IndexPath) -> DebugMenuRow {
        return sections[indexPath.section].rows[indexPath.row]
    }
}
