//
//  DebugMenuFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol DebugMenuFactoryDelegate: AnyObject {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType)
}

class DebugMenuFactory {

    weak var delegate: DebugMenuFactoryDelegate?

    func makeDebugMenuSections() -> [DebugMenuSection] {
        return [makeToolsSection()]
    }
    
    private func makeToolsSection() -> DebugMenuSection {
        return DebugMenuSection(title: "debug_menu_tools_section_title".localized, rows: [makeVersionNumberRow(), makeEndpointRow(), makeEmailAddressRow()])
    }
    
    private func makeVersionNumberRow() -> DebugMenuRow {
        let versionNumber = Bundle.shortVersionNumber ?? ""
        let buildNumber = Bundle.bundleVersion ?? ""
        return DebugMenuRow(title: "Current version", subtitle: String(format: "support_mail_app_version".localized, versionNumber, buildNumber), action: nil)
    }

    private func makeEmailAddressRow() -> DebugMenuRow {
//        let currentEmailAddress = Current.userDefaults.string(forKey: "userEmail")
        let currentEmailAddress = Current.userManager.currentEmailAddress
        return DebugMenuRow(title: "Current email address", subtitle: currentEmailAddress, action: {
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .email)
        })
    }
    
    private func makeEndpointRow() -> DebugMenuRow {
        return DebugMenuRow(title: "Environment Base URL", subtitle: APIConstants.baseURLString, action: nil)
    }
}
