//
//  SettingsViewModel.swift
//  binkapp
//
//  Created by Max Woodhams on 10/10/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SettingsViewModel: UserServiceProtocol {
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
    
    func handleRowActionForAccountDeletion() {
        let alert = ViewControllerFactory.makeOkCancelAlertViewController(title: L10n.settingsDeleteAccountActionTitle, message: L10n.settingsDeleteAccountActionSubtitle, okActionTitle: L10n.deleteActionTitle, cancelButton: true) {
            Current.rootStateMachine.startLoading()
            
            self.deleteService(params: APIConstants.makeServiceRequest(email: Current.userManager.currentEmailAddress ?? "")) { success, _ in
                guard success else {
                    let alert = ViewControllerFactory.makeTwoButtonAlertViewController(title: L10n.errorTitle, message: L10n.settingsDeleteAccountFailedAlertMessage, primaryButtonTitle: L10n.ok, secondaryButtonTitle: L10n.settingsRowContactTitle) {
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
                    } secondaryButtonCompletion: {
                        BinkSupportUtility.launchContactSupport()
                        NotificationCenter.default.post(name: .shouldLogout, object: nil)
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
}
