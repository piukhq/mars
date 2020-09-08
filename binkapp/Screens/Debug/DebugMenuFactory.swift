//
//  DebugMenuFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import Sentry

protocol DebugMenuFactoryDelegate: AnyObject {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType)
}

class DebugMenuFactory {

    weak var delegate: DebugMenuFactoryDelegate?

    func makeDebugMenuSections() -> [DebugMenuSection] {
        return [makeToolsSection()]
    }
    
    private func makeToolsSection() -> DebugMenuSection {
        return DebugMenuSection(title: "debug_menu_tools_section_title".localized, rows: [makeVersionNumberRow(), makeEndpointRow(), makeEmailAddressRow(), makeApiVersionRow(), makeSecondaryColorRow(), makeForceCrashRow()])
    }
    
    private func makeVersionNumberRow() -> DebugMenuRow {
        let versionNumber = Bundle.shortVersionNumber ?? ""
        let buildNumber = Bundle.bundleVersion ?? ""
        return DebugMenuRow(title: "Current version", subtitle: String(format: "support_mail_app_version".localized, versionNumber, buildNumber), action: nil, cellType: .titleSubtitle)
    }

    private func makeEmailAddressRow() -> DebugMenuRow {
        let currentEmailAddress = Current.userManager.currentEmailAddress
        return DebugMenuRow(title: "Current email address", subtitle: currentEmailAddress, action: nil, cellType: .titleSubtitle)
    }
    
    private func makeEndpointRow() -> DebugMenuRow {
        return DebugMenuRow(title: "Environment Base URL", subtitle: APIConstants.baseURLString, action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .endpoint)
            }, cellType: .titleSubtitle)
    }
    
    private func makeApiVersionRow() -> DebugMenuRow {
        return DebugMenuRow(cellType: .segmentedControl)
    }

    private func makeSecondaryColorRow() -> DebugMenuRow {
        return DebugMenuRow(title: "Loyalty card secondary colour swatches", subtitle: nil, action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .secondaryColor)
        }, cellType: .titleSubtitle)
    }
    
    private func makeForceCrashRow() -> DebugMenuRow {
        return DebugMenuRow(title: "Force Crash", subtitle: "This will immediately crash the application", action: {
            SentrySDK.crash()
        }, cellType: .titleSubtitle)
    }
    
    func makeEnvironmentAlertController(navigationController: UINavigationController) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Dev", style: .default, handler: { _ in
            APIConstants.changeEnvironment(environment: .dev)
            NotificationCenter.default.post(name: .shouldLogout, object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Staging", style: .default, handler: { _ in
            APIConstants.changeEnvironment(environment: .staging)
            NotificationCenter.default.post(name: .shouldLogout, object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Pre-production", style: .default, handler: { _ in
            APIConstants.changeEnvironment(environment: .preprod)
            NotificationCenter.default.post(name: .shouldLogout, object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Production", style: .default, handler: { _ in
            APIConstants.changeEnvironment(environment: .production)
            NotificationCenter.default.post(name: .shouldLogout, object: nil)
        }))
        alert.addAction(UIAlertAction(title: "Custom", style: .destructive, handler: { _ in
            let customAlert = UIAlertController(title: "Base URL", message: "Please insert a valid URL.", preferredStyle: .alert)
            customAlert.addTextField { textField in
                textField.placeholder = "api.dev.gb.com"
            }
            if let textField = customAlert.textFields?.first {
                customAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if let textFieldText = textField.text {
                        APIConstants.moveToCustomURL(url: textFieldText)
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    }
                }))
                navigationController.present(customAlert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
}
