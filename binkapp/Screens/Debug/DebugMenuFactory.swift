//
//  DebugMenuFactory.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

protocol DebugMenuFactoryDelegate: AnyObject {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType)
}

class DebugMenuFactory {
    weak var delegate: DebugMenuFactoryDelegate?

    func makeDebugMenuSections() -> [DebugMenuSection] {
        return [makeToolsSection()]
    }
    
    private func makeToolsSection() -> DebugMenuSection {
        return DebugMenuSection(title: "debug_menu_tools_section_title".localized, rows: [makeVersionNumberRow(), makeEndpointRow(), makeEmailAddressRow(), makeApiVersionRow(), makeAllowCustomBundleClientOnLoginRow(), makeSecondaryColorRow(), makeLPCWebViewRow(), makeLPCUseCookiesRow(), makeForceCrashRow(), makeResponseCodeVisualiserRow(), makeInAppReviewRow(), makePLLPromptCounterRow(), makeSeePromptCounterRow(), makeStorePromptCounterRow()])
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
    
    private func makeLPCWebViewRow() -> DebugMenuRow {
        let shouldShow = Current.userDefaults.bool(forDefaultsKey: .lpcDebugWebView)
        return DebugMenuRow(title: "LPC debug web view", subtitle: shouldShow ? "On" : "Off", action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .lpcWebView)
        }, cellType: .titleSubtitle)
    }
    
    private func makeLPCUseCookiesRow() -> DebugMenuRow {
        let shouldUseCookies = Current.userDefaults.bool(forDefaultsKey: .lpcUseCookies)
        return DebugMenuRow(title: "LPC use cookies", subtitle: shouldUseCookies ? "Yes" : "No", action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .lpcCookies)
        }, cellType: .titleSubtitle)
    }
    
    private func makeForceCrashRow() -> DebugMenuRow {
        return DebugMenuRow(title: "Force Crash", subtitle: "This will immediately crash the application", action: {
            SentryService.forceCrash()
        }, cellType: .titleSubtitle)
    }
    
    private func makeResponseCodeVisualiserRow() -> DebugMenuRow {
        let shouldShowVisualiser = Current.userDefaults.bool(forDefaultsKey: .responseCodeVisualiser)
        return DebugMenuRow(title: "Response Code Visualiser", subtitle: shouldShowVisualiser ? "On" : "Off", action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .responseCodeVisualiser)
            }, cellType: .titleSubtitle)
    }

    private func makeInAppReviewRow() -> DebugMenuRow {
        let shouldApplyRules = Current.userDefaults.bool(forDefaultsKey: .applyInAppReviewRules)
        return DebugMenuRow(title: "Apply in-app review rules", subtitle: shouldApplyRules ? "Yes" : "No", action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .inAppReviewRules)
        }, cellType: .titleSubtitle)
    }
    
    private func makePLLPromptCounterRow() -> DebugMenuRow {
        return DebugMenuRow(cellType: .picker(.link))
    }
    
    private func makeSeePromptCounterRow() -> DebugMenuRow {
        return DebugMenuRow(cellType: .picker(.see))
    }
    
    private func makeStorePromptCounterRow() -> DebugMenuRow {
        return DebugMenuRow(cellType: .picker(.store))
    }
    
    private func makeAllowCustomBundleClientOnLoginRow() -> DebugMenuRow {
        let shouldAllowCustomBundleClientOnLogin = Current.userDefaults.bool(forDefaultsKey: .allowCustomBundleClientOnLogin)
        return DebugMenuRow(title: "Allow Custom Bundle and Client on Login/Register", subtitle: shouldAllowCustomBundleClientOnLogin ? "Yes" : "No", action: { [weak self] in
            guard let self = self else { return }
            self.delegate?.debugMenuFactory(self, shouldPerformActionForType: .customBundleClientLogin)
        }, cellType: .titleSubtitle)
    }
    
    func makeEnvironmentAlertController(navigationController: UINavigationController) -> BinkAlertController {
        let alert = BinkAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
            let customAlert = BinkAlertController(title: "Base URL", message: "Please insert a valid URL, removing https:// or http://", preferredStyle: .alert)
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
        alert.pruneNegativeWidthConstraints()
        return alert
    }
}
