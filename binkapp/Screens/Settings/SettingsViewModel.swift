//
//  SettingsViewModel.swift
//  binkapp
//
//  Created by Max Woodhams on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import SwiftUI
import UIKit

class SettingsViewModel: UserServiceProtocol {
    private enum Constants {
        static let privacyPolicyUrl = "https://bink.com/privacy-policy/"
        static let termsAndConditionsUrl = "https://bink.com/terms-and-conditions/"
    }
    
    private let factory: SettingsFactory
    
    init(rowsWithActionRequired: [SettingsRow.RowType]?) {
        factory = SettingsFactory(rowsWithActionRequired: rowsWithActionRequired)
    }
    
    var sections: [SettingsSection] {
        return factory.sectionData()
    }
    
    var title: String {
        return L10n.settingsTitle
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
        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configurationModel, floatingButtons: true)
        Current.navigate.to(PushNavigationRequest(viewController: viewController))
    }
    
    func openWebView(url: String) {
        let viewController = ViewControllerFactory.makeWebViewController(urlString: url)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func shouldShowSeparator(section: SettingsSection, row: SettingsRow) -> Bool {
        if let rowIndex = section.rows.firstIndex(of: row) {
            return (rowIndex + 1) < section.rows.count
        }
        return false
    }
    
    func handleRowActionForAccountDeletion() {
        let alert = ViewControllerFactory.makeOkCancelAlertViewController(title: L10n.settingsDeleteAccountActionTitle, message: L10n.settingsDeleteAccountActionSubtitle, okActionTitle: L10n.deleteActionTitle, cancelButton: true) {
            let navigationRequest = ModalNavigationRequest(viewController: LoadingScreen(), fullScreen: true, embedInNavigationController: false, animated: false, transition: .crossDissolve, dragToDismiss: false, hideCloseButton: true)
            Current.navigate.to(navigationRequest)
            
            self.deleteService(params: APIConstants.makeServiceRequest(email: Current.userManager.currentEmailAddress ?? "")) { success, _ in
                guard success else {
                    let alert = ViewControllerFactory.makeTwoButtonAlertViewController(title: L10n.errorTitle, message: L10n.settingsDeleteAccountFailedAlertMessage, primaryButtonTitle: L10n.ok, secondaryButtonTitle: L10n.contactUsActionTitle) {
                        Current.navigate.close()
                    } secondaryButtonCompletion: {
                        Current.navigate.close() {
                            BinkSupportUtility.launchContactSupport()
                        }
                    }

                    let navigationRequest = AlertNavigationRequest(alertController: alert)
                    Current.navigate.to(navigationRequest)
                    return
                }
                
                let okAlertViewController = ViewControllerFactory.makeOkAlertViewController(title: L10n.settingsDeleteAccountSuccessAlertMessage, message: nil) {
                    NotificationCenter.default.post(name: .shouldLogout, object: nil)
                }
                let navigationRequest = AlertNavigationRequest(alertController: okAlertViewController)
                Current.navigate.to(navigationRequest)
            }
        }
        let navigationRequest = AlertNavigationRequest(alertController: alert)
        Current.navigate.to(navigationRequest)
    }
    
    func handleRowAction(for row: SettingsRow) {
        switch row.action {
        case .customAction(let action):
            action()
        case .navigate(let destination):
            switch destination {
            case .whoWeAre:
                navigate(to: WhoWeAreSwiftUIView())
            case .featureFlags:
                navigate(to: FeatureFlagsSwiftUIView()) /// <<<<<<<<<<< Do we need delegate to refresh settings list after feature flags have updated
            case .debug:
                navigate(to: DebugMenuView())
            case .securityAndPrivacy:
                navigate(to: ReusableTemplateView(title: L10n.securityAndPrivacyTitle, description: L10n.securityAndPrivacyDescription))
            case .howItWorks:
                navigate(to: ReusableTemplateView(title: L10n.howItWorksTitle, description: L10n.howItWorksDescription))
            case .privacyPolicy:
                openWebView(url: Constants.privacyPolicyUrl)
            case .termsAndConditions:
                openWebView(url: Constants.termsAndConditionsUrl)
            }
        case .logout:
            let alert = BinkAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "Log out", style: .default, handler: { _ in
                    NotificationCenter.default.post(name: .shouldLogout, object: nil)
                })
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            let navigationRequest = AlertNavigationRequest(alertController: alert)
            Current.navigate.to(navigationRequest)
        case .launchSupport(service: let service):
            switch service {
            case .faq:
                BinkSupportUtility.launchFAQs()
            case .contactUs:
                BinkSupportUtility.launchContactSupport()
            }
        case .delete:
                handleRowActionForAccountDeletion()
        default:
            break
        }
    }
    
    private func navigate<Content: View>(to view: Content) {
        let hostingViewController = UIHostingController(rootView: view)
        let navigationRequest = PushNavigationRequest(viewController: hostingViewController)
        Current.navigate.to(navigationRequest)
    }
}
