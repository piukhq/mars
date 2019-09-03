//
//  DebugMenuFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct DebugMenuFactory {
    func makeDebugMenuSections() -> [DebugMenuSection] {
        return [makeToolsSection()]
    }
    
    private func makeToolsSection() -> DebugMenuSection {
        return DebugMenuSection(title: "debug_menu_tools_section_title".localized, rows: [makeVersionNumberRow()])
    }
    
    private func makeVersionNumberRow() -> DebugMenuRow {
        let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return DebugMenuRow(title: "Current version", subtitle: "\(versionNumber ?? "") build \(buildNumber ?? "")", action: nil)
    }
}
