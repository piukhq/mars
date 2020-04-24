//
//  SettingsViewModelMock.swift
//  binkapp
//
//  Created by Pop Dorin on 15/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class SettingsViewModelMock: NSObject {
    private let factory = SettingsFactoryMock()
    
    var sections: [SettingsSection] {
        return factory.sectionData()
    }
    
    var title: String {
        return "settings_title".localized
    }
    
    var sectionsCount: Int {
        return sections.count
    }
    
    var cellHeight: CGFloat {
        return 60
    }
    
    func rowsCount(forSectionAtIndex index: Int) -> Int {
        return sections[safe: index]?.rows.count ?? 0
    }
    
    func titleForSection(atIndex index: Int) -> String? {
        return sections[safe: index]?.title
    }
    
    func row(atIndexPath indexPath: IndexPath) -> SettingsRow? {
        return sections[safe: indexPath.section]?.rows[safe: indexPath.row]
    }
}
