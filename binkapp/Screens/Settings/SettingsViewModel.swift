//
//  SettingsViewModel.swift
//  binkapp
//
//  Created by Max Woodhams on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SettingsViewModel {
    private let factory: SettingsFactory
    
    init(rowsWithActionRequired: [SettingsRow.RowType]?) {
        factory = SettingsFactory(rowsWithActionRequired: rowsWithActionRequired)
    }
    
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
    
    func pushReusableModal(configurationModel: ReusableModalConfiguration) {
        let viewModel = ReusableModalViewModel(configurationModel: configurationModel)
        let viewController = ReusableTemplateViewController(viewModel: viewModel, floatingButtons: true)
        Current.navigate.to(PushNavigationRequest(viewController: viewController))
    }
    
    func openWebView(url: String) {
//        router.openWebView(withUrlString: url)
    }
}
